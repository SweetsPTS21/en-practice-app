import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design/widgets/app_button.dart';
import '../../core/design/widgets/app_card.dart';
import '../../core/design/widgets/app_header_icon_action.dart';
import '../../core/design/widgets/app_page_scaffold.dart';
import '../../core/design/widgets/app_state_widgets.dart';
import '../../core/ielts/ielts_models.dart';
import '../../core/ielts/ielts_providers.dart';
import '../../core/navigation/app_route_contract.dart';
import '../../core/navigation/learning_launch_store.dart';
import '../../core/theme/page_palettes.dart';
import '../../core/theme/theme_extensions.dart';
import '../ielts/application/ielts_controllers.dart';
import '../../core/learning_journey/learning_journey_providers.dart';

class IeltsPage extends ConsumerStatefulWidget {
  const IeltsPage({super.key, required this.initialUri});

  final Uri initialUri;

  @override
  ConsumerState<IeltsPage> createState() => _IeltsPageState();
}

class _IeltsPageState extends ConsumerState<IeltsPage> {
  bool _handledInitialIntent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialIntent) {
      return;
    }
    _handledInitialIntent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleInitialIntent());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ieltsListControllerProvider);
    final controller = ref.read(ieltsListControllerProvider.notifier);
    final attempts =
        state.valueOrNull?.attempts ?? const <IeltsAttemptHistoryItem>[];
    final heroTrailing = attempts.isNotEmpty
        ? AppHeaderIconAction(
            tooltip: 'Attempts',
            icon: Icons.history_rounded,
            onPressed: () => _openAttemptsSheet(attempts),
          )
        : null;

    return AppPageScaffold(
      title: 'IELTS assessment',
      subtitle:
          'Browse tests, reopen unfinished attempts, and launch quick or full practice.',
      paletteKey: AppPagePaletteKey.ielts,
      trailing: heroTrailing,
      onRefresh: controller.refresh,
      children: [
        ...state.when(
          data: (value) => [
            _SkillFilterCard(
              selectedSkill: switch (value.resolvedQuery.skill) {
                'READING' => IeltsSkill.reading,
                'LISTENING' => IeltsSkill.listening,
                _ => null,
              },
              onSelected: controller.selectSkill,
            ),
            if (!value.tests.hasItems)
              const AppEmptyState(
                icon: Icons.school_rounded,
                title: 'No IELTS tests available',
                subtitle: 'Pull to refresh or try another skill filter.',
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available tests',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    for (
                      var index = 0;
                      index < value.tests.items.length;
                      index++
                    ) ...[
                      _IeltsTestTile(test: value.tests.items[index]),
                      if (index != value.tests.items.length - 1)
                        const SizedBox(height: 12),
                    ],
                    if (value.tests.totalPages > 1) ...[
                      const SizedBox(height: 16),
                      _PaginationBar(
                        currentPage: value.tests.page + 1,
                        totalPages: math.max(value.tests.totalPages, 1),
                        onPrev: value.tests.page == 0
                            ? null
                            : () => controller.goToPage(value.tests.page - 1),
                        onNext: value.tests.hasNextPage
                            ? () => controller.goToPage(value.tests.page + 1)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
          ],
          error: (_, _) => [
            AppErrorCard(
              title: 'IELTS unavailable',
              message: 'The IELTS catalog could not be loaded right now.',
              onRetry: () => ref.invalidate(ieltsListControllerProvider),
            ),
          ],
          loading: () => const [
            AppLoadingCard(height: 220, message: 'Loading IELTS practice...'),
          ],
        ),
      ],
    );
  }

  Future<void> _handleInitialIntent() async {
    final intent = IeltsLaunchIntent.fromUri(widget.initialUri);
    final testId = intent.testId;
    if (testId == null || testId.isEmpty) {
      return;
    }

    if (intent.hasDirectStart) {
      try {
        final session = await ref
            .read(ieltsApiProvider)
            .startSession(
              IeltsStartSessionPayload(
                testId: testId,
                attemptMode: intent.attemptMode!,
                scopeType: intent.scopeType!,
                scopeId: intent.scopeId,
              ),
            );
        await _rewritePendingLaunch(
          fromRoute: widget.initialUri.toString(),
          toRoute: '/ielts/take/${session.attemptId}',
        );
        if (mounted) {
          context.go('/ielts/take/${session.attemptId}');
        }
      } catch (_) {
        if (mounted) {
          context.go('/ielts/test/$testId${_querySuffix(widget.initialUri)}');
        }
      }
      return;
    }

    if (mounted) {
      context.go('/ielts/test/$testId${_querySuffix(widget.initialUri)}');
    }
  }

  Future<void> _rewritePendingLaunch({
    required String fromRoute,
    required String toRoute,
  }) async {
    final store = ref.read(learningLaunchStoreProvider);
    final current = store.getPendingLearningLaunch();
    if (current == null || !routesMatch(current.route, fromRoute)) {
      return;
    }
    await store.rememberLearningLaunch(
      LearningLaunchContext(
        source: current.source,
        route: toRoute,
        started: false,
        launchedAt: current.launchedAt,
        module: current.module,
        referenceType: current.referenceType,
        referenceId: current.referenceId,
        taskId: current.taskId,
        taskTitle: current.taskTitle,
        reason: current.reason,
        estimatedMinutes: current.estimatedMinutes,
        priority: current.priority,
        metadata: current.metadata,
      ),
    );
  }

  String _querySuffix(Uri uri) => uri.hasQuery ? '?${uri.query}' : '';

  Future<void> _openAttemptsSheet(
    List<IeltsAttemptHistoryItem> attempts,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.tokens.background.canvas,
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: _AttemptHistorySheet(
              attempts: attempts,
              onSelected: (attempt) {
                Navigator.of(sheetContext).pop();
                final target = attempt.status.isFinished
                    ? '/ielts/result/${attempt.attemptId}'
                    : '/ielts/take/${attempt.attemptId}';
                context.go(target);
              },
            ),
          ),
        );
      },
    );
  }
}

class _AttemptHistorySheet extends StatelessWidget {
  const _AttemptHistorySheet({
    required this.attempts,
    required this.onSelected,
  });

  final List<IeltsAttemptHistoryItem> attempts;
  final ValueChanged<IeltsAttemptHistoryItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent attempts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Resume unfinished work or open the latest result.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.tokens.text.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: attempts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final attempt = attempts[index];
                return _AttemptHistoryTile(
                  attempt: attempt,
                  onTap: () => onSelected(attempt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptHistoryTile extends StatelessWidget {
  const _AttemptHistoryTile({required this.attempt, required this.onTap});

  final IeltsAttemptHistoryItem attempt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.background.panelStrong,
            borderRadius: BorderRadius.circular(tokens.radius.xl),
            border: Border.all(color: tokens.border.subtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tokens.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                ),
                child: Icon(
                  attempt.status.isFinished
                      ? Icons.insights_rounded
                      : Icons.play_circle_outline_rounded,
                  color: tokens.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attempt.testTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${attempt.skill.label} · ${attempt.attemptMode.label} · ${attempt.primaryScoreDisplay}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right_rounded, color: tokens.text.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppButton(
            label: 'Prev',
            compact: true,
            variant: AppButtonVariant.outline,
            onPressed: onPrev,
          ),
          const SizedBox(width: 12),
          Text(
            '$currentPage / $totalPages',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(width: 12),
          AppButton(label: 'Next', compact: true, onPressed: onNext),
        ],
      ),
    );
  }
}

class _SkillFilterCard extends StatelessWidget {
  const _SkillFilterCard({
    required this.selectedSkill,
    required this.onSelected,
  });

  final IeltsSkill? selectedSkill;
  final ValueChanged<IeltsSkill?> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skill focus', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'All',
                selected: selectedSkill == null,
                onPressed: () => onSelected(null),
              ),
              _FilterChip(
                label: 'Reading',
                selected: selectedSkill == IeltsSkill.reading,
                onPressed: () => onSelected(IeltsSkill.reading),
              ),
              _FilterChip(
                label: 'Listening',
                selected: selectedSkill == IeltsSkill.listening,
                onPressed: () => onSelected(IeltsSkill.listening),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = selected ? tokens.primary : tokens.text.secondary;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.14 : 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
        ),
      ),
    );
  }
}

class _IeltsTestTile extends StatelessWidget {
  const _IeltsTestTile({required this.test});

  final IeltsTestSummary test;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scoreLabel = test.highestScore == null
        ? null
        : (test.skill == IeltsSkill.listening ||
              test.skill == IeltsSkill.reading)
        ? (test.highestScore!.bandScore != null
              ? 'Band ${test.highestScore!.bandScore!.toStringAsFixed(1)}'
              : test.highestScore!.accuracyPercent == null
              ? null
              : '${test.highestScore!.accuracyPercent!.toStringAsFixed(0)}%')
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${test.skill.label} · ${test.questionCount} questions · ${test.estimatedMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.text.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (scoreLabel != null) ...[
                const SizedBox(width: 12),
                Text(
                  scoreLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: tokens.success),
                ),
              ],
            ],
          ),
          if ((test.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(test.description!),
          ],
          if (test.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: test.tags
                  .take(3)
                  .map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.background.panel,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: tokens.border.subtle),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: tokens.text.secondary),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.go('/ielts/test/${test.testId}'),
                  icon: const Icon(Icons.article_outlined),
                  label: const Text('Open'),
                ),
              ),
              if ((test.latestAttemptId ?? '').isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.go('/ielts/take/${test.latestAttemptId}'),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Resume'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
