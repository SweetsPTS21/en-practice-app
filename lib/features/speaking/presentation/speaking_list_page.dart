import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/theme/theme_tokens.dart';
import '../application/speaking_controllers.dart';
import 'speaking_history_page.dart';

const List<_FilterOption> _speakingPartFilters = <_FilterOption>[
  _FilterOption('ALL', 'All'),
  _FilterOption('PART_1', 'Part 1'),
  _FilterOption('PART_2', 'Part 2'),
  _FilterOption('PART_3', 'Part 3'),
];

const List<_FilterOption> _speakingLevelFilters = <_FilterOption>[
  _FilterOption('ALL', 'All'),
  _FilterOption('EASY', 'Easy'),
  _FilterOption('MEDIUM', 'Medium'),
  _FilterOption('HARD', 'Hard'),
];

class SpeakingListPage extends ConsumerWidget {
  const SpeakingListPage({super.key, this.mode});

  final String? mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(speakingListControllerProvider);
    final controller = ref.read(speakingListControllerProvider.notifier);
    final tokens = context.tokens;

    return AppPageScaffold(
      title: 'Speaking practice',
      subtitle: 'Pick a prompt, record once, or jump into a guide.',
      paletteKey: AppPagePaletteKey.speaking,
      trailing: AppHeaderIconAction(
        tooltip: 'History',
        icon: Icons.history_rounded,
        onPressed: () => _openSpeakingHistorySheet(context),
      ),
      onRefresh: controller.refresh,
      children: [
        if ((mode ?? '').isNotEmpty)
          AppCard(
            strong: true,
            child: Row(
              children: [
                _ModeBadge(
                  icon: mode == 'daily'
                      ? Icons.bolt_rounded
                      : Icons.flash_on_rounded,
                  label: mode == 'daily' ? 'Daily mode' : 'Quick mode',
                ),
                const Spacer(),
                const Icon(Icons.tips_and_updates_outlined),
              ],
            ),
          ),
        ...state.when(
          data: (value) => [
            AppCard(
              strong: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Icon(
                      Icons.filter_alt_outlined,
                      color: tokens.text.secondary,
                    ),
                  ),
                  SizedBox(width: tokens.density.compactGap),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _FilterDropdown(
                            key: ValueKey(
                              'speaking-part-${value.query.part ?? 'ALL'}',
                            ),
                            label: 'Part',
                            value: value.query.part ?? 'ALL',
                            items: _speakingPartFilters,
                            onChanged: controller.updatePart,
                          ),
                        ),
                        SizedBox(width: tokens.density.compactGap),
                        Expanded(
                          child: _FilterDropdown(
                            key: ValueKey(
                              'speaking-level-${value.query.difficulty ?? 'ALL'}',
                            ),
                            label: 'Level',
                            value: value.query.difficulty ?? 'ALL',
                            items: _speakingLevelFilters,
                            onChanged: controller.updateDifficulty,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modes', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: tokens.density.regularGap),
                  _ShortcutTile(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Custom',
                    onTap: () => context.go('/custom-speaking'),
                  ),
                  SizedBox(height: tokens.density.compactGap),
                  _ShortcutTile(
                    icon: Icons.history_edu_rounded,
                    title: 'Guide history',
                    onTap: () => context.go('/speaking/conversation/history'),
                  ),
                ],
              ),
            ),
            if (!value.topics.hasItems)
              const AppEmptyState(
                icon: Icons.mic_none_rounded,
                title: 'No topics',
                subtitle: 'Pull to refresh later.',
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: tokens.density.regularGap),
                    for (
                      var index = 0;
                      index < value.topics.items.length;
                      index++
                    ) ...[
                      _SpeakingTopicTile(
                        title: value.topics.items[index].question,
                        part: value.topics.items[index].part,
                        difficulty: value.topics.items[index].difficulty,
                        attempted:
                            value
                                .highestScoreFor(value.topics.items[index].id)
                                ?.attempted ??
                            false,
                        isPending: _isPendingStatus(
                          value
                              .highestScoreFor(value.topics.items[index].id)
                              ?.status,
                        ),
                        bandScore: value
                            .highestScoreFor(value.topics.items[index].id)
                            ?.highestBandScore,
                        onPractice: () => context.go(
                          '/speaking/practice/${value.topics.items[index].id}',
                        ),
                        onConversation: () => context.go(
                          '/speaking/conversation/${value.topics.items[index].id}',
                        ),
                        onBestResult:
                            value
                                    .highestScoreFor(
                                      value.topics.items[index].id,
                                    )
                                    ?.attemptId ==
                                null
                            ? null
                            : () => context.go(
                                '/speaking/result/${value.highestScoreFor(value.topics.items[index].id)!.attemptId}',
                              ),
                      ),
                      if (index != value.topics.items.length - 1)
                        SizedBox(height: tokens.density.compactGap),
                    ],
                  ],
                ),
              ),
          ],
          error: (_, _) => [
            AppErrorCard(
              title: 'Speaking unavailable',
              message: 'Try again in a moment.',
              onRetry: () => ref.invalidate(speakingListControllerProvider),
            ),
          ],
          loading: () => const [
            AppLoadingCard(height: 260, message: 'Loading speaking topics...'),
          ],
        ),
      ],
    );
  }
}

Future<void> _openSpeakingHistorySheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.tokens.background.canvas,
    builder: (sheetContext) {
      return SpeakingHistorySheet(
        onSelected: (item) {
          Navigator.of(sheetContext).pop();
          context.go('/speaking/result/${item.id}');
        },
      );
    },
  );
}

class _SpeakingTopicTile extends StatelessWidget {
  const _SpeakingTopicTile({
    required this.title,
    required this.part,
    required this.difficulty,
    required this.attempted,
    required this.isPending,
    required this.bandScore,
    required this.onPractice,
    required this.onConversation,
    this.onBestResult,
  });

  final String title;
  final String part;
  final String difficulty;
  final bool attempted;
  final bool isPending;
  final double? bandScore;
  final VoidCallback onPractice;
  final VoidCallback onConversation;
  final VoidCallback? onBestResult;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.speaking);
    final status = _buildStatus(tokens);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.background.panelStrong,
            palette.accentSoft.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        border: Border.all(color: palette.accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radius.lg),
                  border: Border.all(
                    color: palette.accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(_partIcon(part), size: 18, color: palette.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: 12),
                Text(
                  status.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: status.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: _partIcon(part), label: _partLabel(part)),
              _MetaChip(
                icon: Icons.signal_cellular_alt_rounded,
                label: _levelLabel(difficulty),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Speak',
                  icon: Icons.mic_rounded,
                  compact: true,
                  onPressed: onPractice,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Guide',
                  icon: Icons.forum_rounded,
                  compact: true,
                  variant: AppButtonVariant.outline,
                  onPressed: onConversation,
                ),
              ),
              if (onBestResult != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Best',
                    icon: Icons.insights_rounded,
                    compact: true,
                    variant: AppButtonVariant.tonal,
                    onPressed: onBestResult,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _StatusData? _buildStatus(AppThemeTokens tokens) {
    if (isPending) {
      return _StatusData(label: 'Pending', color: tokens.warning);
    }

    if (bandScore != null) {
      return _StatusData(
        label: 'Band ${bandScore!.toStringAsFixed(1)}',
        color: tokens.success,
      );
    }

    if (attempted) {
      return _StatusData(label: 'Done', color: tokens.primary);
    }

    return null;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.background.canvas.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border.subtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tokens.text.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.text.secondary),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<_FilterOption> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isDense: true,
      initialValue: value,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.value,
              child: Text(item.label),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radius.xl),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tokens.background.panelStrong,
          borderRadius: BorderRadius.circular(tokens.radius.xl),
          border: Border.all(color: tokens.border.subtle),
        ),
        child: Row(
          children: [
            Icon(icon, color: tokens.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border.accent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: tokens.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: tokens.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption(this.value, this.label);

  final String value;
  final String label;
}

class _StatusData {
  const _StatusData({required this.label, required this.color});

  final String label;
  final Color color;
}

String _partLabel(String value) {
  return switch (value) {
    'PART_1' => 'Part 1',
    'PART_2' => 'Part 2',
    'PART_3' => 'Part 3',
    _ => value.replaceAll('_', ' '),
  };
}

IconData _partIcon(String value) {
  return switch (value) {
    'PART_1' => Icons.chat_bubble_outline_rounded,
    'PART_2' => Icons.assignment_outlined,
    'PART_3' => Icons.forum_outlined,
    _ => Icons.mic_none_rounded,
  };
}

String _levelLabel(String value) {
  return switch (value) {
    'EASY' => 'Easy',
    'MEDIUM' => 'Medium',
    'HARD' => 'Hard',
    _ => value,
  };
}

bool _isPendingStatus(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    'PENDING' || 'SUBMITTED' || 'GRADING' => true,
    _ => false,
  };
}
