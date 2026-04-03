import 'dart:math' as math;

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
import '../application/writing_controllers.dart';

const List<_FilterOption> _writingTypeFilters = <_FilterOption>[
  _FilterOption('ALL', 'All'),
  _FilterOption('TASK_1', 'Task 1'),
  _FilterOption('TASK_2', 'Task 2'),
  _FilterOption('GENERAL', 'General'),
];

const List<_FilterOption> _writingLevelFilters = <_FilterOption>[
  _FilterOption('ALL', 'All'),
  _FilterOption('EASY', 'Easy'),
  _FilterOption('MEDIUM', 'Medium'),
  _FilterOption('HARD', 'Hard'),
];

class WritingListPage extends ConsumerWidget {
  const WritingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingListControllerProvider);
    final controller = ref.read(writingListControllerProvider.notifier);
    final tokens = context.tokens;

    return AppPageScaffold(
      title: 'Writing practice',
      subtitle: 'Pick a task, write fast, review your best band.',
      paletteKey: AppPagePaletteKey.writing,
      trailing: AppHeaderIconAction(
        tooltip: 'History',
        icon: Icons.history_rounded,
        onPressed: () => context.go('/writing/history'),
      ),
      onRefresh: controller.refresh,
      children: [
        ...state.when(
          data: (value) {
            final currentPage = value.tasks.page + 1;
            final totalPages = math.max(value.tasks.totalPages, 1);

            return [
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
                                'writing-type-${value.query.taskType ?? 'ALL'}',
                              ),
                              label: 'Type',
                              value: value.query.taskType ?? 'ALL',
                              items: _writingTypeFilters,
                              onChanged: controller.updateTaskType,
                            ),
                          ),
                          SizedBox(width: tokens.density.compactGap),
                          Expanded(
                            child: _FilterDropdown(
                              key: ValueKey(
                                'writing-level-${value.query.difficulty ?? 'ALL'}',
                              ),
                              label: 'Level',
                              value: value.query.difficulty ?? 'ALL',
                              items: _writingLevelFilters,
                              onChanged: controller.updateDifficulty,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!value.tasks.hasItems)
                const AppEmptyState(
                  icon: Icons.edit_note_rounded,
                  title: 'No tasks',
                  subtitle: 'Change filters or pull to refresh.',
                )
              else
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: tokens.density.regularGap),
                      for (
                        var index = 0;
                        index < value.tasks.items.length;
                        index++
                      ) ...[
                        _WritingTaskTile(
                          taskTitle: value.tasks.items[index].title,
                          taskType: value.tasks.items[index].taskType,
                          difficulty: value.tasks.items[index].difficulty,
                          timeLimitMinutes:
                              value.tasks.items[index].timeLimitMinutes,
                          minWords: value.tasks.items[index].minWords,
                          maxWords: value.tasks.items[index].maxWords,
                          attempted:
                              value
                                  .highestScoreFor(value.tasks.items[index].id)
                                  ?.attempted ??
                              false,
                          isPending:
                              value
                                  .highestScoreFor(value.tasks.items[index].id)
                                  ?.isPending ??
                              false,
                          bandScore: value
                              .highestScoreFor(value.tasks.items[index].id)
                              ?.highestBandScore,
                          onOpen: () => context.go(
                            '/writing/task/${value.tasks.items[index].id}',
                          ),
                          onResume: () => context.go(
                            '/writing/task/${value.tasks.items[index].id}/take',
                          ),
                          onBestResult:
                              value
                                      .highestScoreFor(
                                        value.tasks.items[index].id,
                                      )
                                      ?.submissionId ==
                                  null
                              ? null
                              : () => context.go(
                                  '/writing/submission/${value.highestScoreFor(value.tasks.items[index].id)!.submissionId}',
                                ),
                        ),
                        if (index != value.tasks.items.length - 1)
                          SizedBox(height: tokens.density.compactGap),
                      ],
                      if (value.tasks.totalPages > 1) ...[
                        SizedBox(height: tokens.density.regularGap),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.background.panelStrong,
                            borderRadius: BorderRadius.circular(
                              tokens.radius.xl,
                            ),
                            border: Border.all(color: tokens.border.subtle),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppButton(
                                label: 'Prev',
                                compact: true,
                                variant: AppButtonVariant.outline,
                                onPressed: value.tasks.page == 0
                                    ? null
                                    : () => controller.goToPage(
                                        value.tasks.page - 1,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$currentPage / $totalPages',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(width: 12),
                              AppButton(
                                label: 'Next',
                                compact: true,
                                onPressed: value.tasks.hasNextPage
                                    ? () => controller.goToPage(
                                        value.tasks.page + 1,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ];
          },
          error: (_, _) => [
            AppErrorCard(
              title: 'Writing unavailable',
              message: 'Try again in a moment.',
              onRetry: () => ref.invalidate(writingListControllerProvider),
            ),
          ],
          loading: () => const [
            AppLoadingCard(height: 240, message: 'Loading writing tasks...'),
          ],
        ),
      ],
    );
  }
}

class _WritingTaskTile extends StatelessWidget {
  const _WritingTaskTile({
    required this.taskTitle,
    required this.taskType,
    required this.difficulty,
    required this.timeLimitMinutes,
    required this.minWords,
    required this.maxWords,
    required this.attempted,
    required this.isPending,
    required this.bandScore,
    required this.onOpen,
    required this.onResume,
    this.onBestResult,
  });

  final String taskTitle;
  final String taskType;
  final String difficulty;
  final int timeLimitMinutes;
  final int minWords;
  final int maxWords;
  final bool attempted;
  final bool isPending;
  final double? bandScore;
  final VoidCallback onOpen;
  final VoidCallback onResume;
  final VoidCallback? onBestResult;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.pagePalette(AppPagePaletteKey.writing);
    final status = _buildStatus(tokens);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.background.panelStrong,
            palette.accentSoft.withValues(alpha: 0.32),
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
                child: Icon(
                  _taskTypeIcon(taskType),
                  size: 18,
                  color: palette.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  taskTitle,
                  maxLines: 2,
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
              _MetaChip(
                icon: _taskTypeIcon(taskType),
                label: _taskTypeLabel(taskType),
              ),
              _MetaChip(
                icon: Icons.signal_cellular_alt_rounded,
                label: _levelLabel(difficulty),
              ),
              _MetaChip(
                icon: Icons.schedule_rounded,
                label: '${timeLimitMinutes}m',
              ),
              _MetaChip(
                icon: Icons.short_text_rounded,
                label: '$minWords-$maxWords',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Open',
                  icon: Icons.description_outlined,
                  compact: true,
                  variant: AppButtonVariant.outline,
                  onPressed: onOpen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Write',
                  icon: Icons.edit_rounded,
                  compact: true,
                  onPressed: onResume,
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

String _taskTypeLabel(String value) {
  return switch (value) {
    'TASK_1' => 'Task 1',
    'TASK_2' => 'Task 2',
    'GENERAL' => 'General',
    _ => value.replaceAll('_', ' '),
  };
}

IconData _taskTypeIcon(String value) {
  return switch (value) {
    'TASK_1' => Icons.bar_chart_rounded,
    'TASK_2' => Icons.edit_note_rounded,
    'GENERAL' => Icons.article_rounded,
    _ => Icons.edit_document,
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
