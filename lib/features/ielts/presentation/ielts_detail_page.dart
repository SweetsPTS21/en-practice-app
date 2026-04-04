import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/ielts/ielts_models.dart';
import '../../../core/ielts/ielts_providers.dart';
import '../../../core/navigation/app_route_contract.dart';
import '../../../core/navigation/learning_launch_store.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../ielts/application/ielts_controllers.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import 'widgets/ielts_markdown_block.dart';

class IeltsDetailPage extends ConsumerStatefulWidget {
  const IeltsDetailPage({
    super.key,
    required this.testId,
    required this.initialUri,
  });

  final String testId;
  final Uri initialUri;

  @override
  ConsumerState<IeltsDetailPage> createState() => _IeltsDetailPageState();
}

class _IeltsDetailPageState extends ConsumerState<IeltsDetailPage> {
  bool _handledInitialIntent = false;
  bool _isStarting = false;

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
    final detail = ref.watch(ieltsDetailProvider(widget.testId));
    return AppPageScaffold(
      title: 'IELTS detail',
      subtitle: 'Review sections, choose scope, and start the real session.',
      paletteKey: AppPagePaletteKey.ielts,
      onRefresh: () async {
        ref.invalidate(ieltsDetailProvider(widget.testId));
      },
      children: [
        switch (detail) {
          AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  strong: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value.detail.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 10),
                      Text(
                        '${value.detail.skill.label} · ${value.detail.questionCount} questions · ${value.detail.estimatedMinutes} min',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.tokens.text.secondary,
                        ),
                      ),
                      if ((value.detail.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(value.detail.description!),
                      ],
                      if ((value.detail.instructions ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        IeltsMarkdownBlock(data: value.detail.instructions!),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isStarting
                                  ? null
                                  : () => _startSession(
                                      const IeltsStartSessionPayload(
                                        testId: '',
                                        attemptMode: IeltsAttemptMode.full,
                                        scopeType: IeltsScopeType.fullTest,
                                      ),
                                      overrideTestId: value.detail.testId,
                                    ),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(_isStarting ? 'Starting...' : 'Start full test'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.tonalIcon(
                              onPressed: _isStarting
                                  ? null
                                  : () => _openPracticeOptions(value),
                              icon: const Icon(Icons.tune_rounded),
                              label: const Text('Quick practice'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < value.detail.sections.length; index++) ...[
                  _SectionOverviewCard(section: value.detail.sections[index]),
                  if (index != value.detail.sections.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          AsyncError() => AppErrorCard(
              title: 'IELTS detail unavailable',
              message: 'This test could not be loaded right now.',
              onRetry: () => ref.invalidate(ieltsDetailProvider(widget.testId)),
            ),
          _ => const AppLoadingCard(height: 240, message: 'Loading test detail...'),
        },
      ],
    );
  }

  Future<void> _handleInitialIntent() async {
    final intent = IeltsLaunchIntent.fromUri(widget.initialUri);
    if (!intent.hasDirectStart || intent.testId != widget.testId) {
      return;
    }
    await _startSession(
      IeltsStartSessionPayload(
        testId: widget.testId,
        attemptMode: intent.attemptMode!,
        scopeType: intent.scopeType!,
        scopeId: intent.scopeId,
      ),
    );
  }

  Future<void> _openPracticeOptions(IeltsDetailBundle bundle) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.tokens.background.canvas,
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.88,
            child: _PracticeOptionsSheet(
              bundle: bundle,
              onSelected: (payload) {
                Navigator.of(sheetContext).pop();
                _startSession(payload);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _startSession(
    IeltsStartSessionPayload payload, {
    String? overrideTestId,
  }) async {
    if (_isStarting) {
      return;
    }
    setState(() => _isStarting = true);
    try {
      final effectivePayload = IeltsStartSessionPayload(
        testId: overrideTestId ?? payload.testId,
        attemptMode: payload.attemptMode,
        scopeType: payload.scopeType,
        scopeId: payload.scopeId,
      );
      final session = await ref.read(ieltsApiProvider).startSession(effectivePayload);
      await _rewritePendingLaunch(
        fromRoute: widget.initialUri.toString(),
        toRoute: '/ielts/take/${session.attemptId}',
      );
      if (mounted) {
        context.go('/ielts/take/${session.attemptId}');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
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
}

class _SectionOverviewCard extends StatelessWidget {
  const _SectionOverviewCard({required this.section});

  final IeltsSectionSummary section;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
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
                    Text(section.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${section.questionCount} questions',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.text.secondary),
                    ),
                  ],
                ),
              ),
              if ((section.audioUrl ?? '').isNotEmpty)
                Text(
                  'Audio',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: tokens.primary,
                  ),
                ),
            ],
          ),
          if ((section.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            IeltsMarkdownBlock(data: section.description!),
          ],
          if (section.passages.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var index = 0; index < section.passages.length; index++) ...[
              Text(
                'Passage ${index + 1}: ${section.passages[index].title}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (index != section.passages.length - 1) const SizedBox(height: 6),
            ],
          ],
        ],
      ),
    );
  }
}

class _PracticeOptionsSheet extends StatelessWidget {
  const _PracticeOptionsSheet({
    required this.bundle,
    required this.onSelected,
  });

  final IeltsDetailBundle bundle;
  final ValueChanged<IeltsStartSessionPayload> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text('Practice options', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Quick practice reuses the scoped session contract from backend. Pick a section or a passage exactly as the API exposes it.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.tokens.text.secondary,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => onSelected(
            IeltsStartSessionPayload(
              testId: bundle.detail.testId,
              attemptMode: IeltsAttemptMode.full,
              scopeType: IeltsScopeType.fullTest,
            ),
          ),
          icon: const Icon(Icons.school_rounded),
          label: const Text('Start full test'),
        ),
        const SizedBox(height: 16),
        for (final section in bundle.practiceOptions.sections) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '${section.questionCount} questions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.tokens.text.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => onSelected(
                    IeltsStartSessionPayload(
                      testId: bundle.detail.testId,
                      attemptMode: IeltsAttemptMode.quick,
                      scopeType: IeltsScopeType.section,
                      scopeId: section.id,
                    ),
                  ),
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('Practice this section'),
                ),
                if (section.passages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  for (var index = 0; index < section.passages.length; index++) ...[
                    _PassageOptionTile(
                      sectionTitle: section.title,
                      passage: section.passages[index],
                      onSelected: () => onSelected(
                        IeltsStartSessionPayload(
                          testId: bundle.detail.testId,
                          attemptMode: IeltsAttemptMode.quick,
                          scopeType: IeltsScopeType.passage,
                          scopeId: section.passages[index].id,
                        ),
                      ),
                    ),
                    if (index != section.passages.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PassageOptionTile extends StatelessWidget {
  const _PassageOptionTile({
    required this.sectionTitle,
    required this.passage,
    required this.onSelected,
  });

  final String sectionTitle;
  final IeltsPracticePassageOption passage;
  final VoidCallback onSelected;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(passage.title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            '${passage.questionCount} questions · $sectionTitle',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.text.secondary,
            ),
          ),
          if ((passage.audioSeekHint ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              passage.audioSeekHint!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: tokens.primary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          FilledButton.tonal(
            onPressed: passage.sharedContextOnly ? null : onSelected,
            child: Text(
              passage.sharedContextOnly ? 'Context only' : 'Practice this passage',
            ),
          ),
        ],
      ),
    );
  }
}
