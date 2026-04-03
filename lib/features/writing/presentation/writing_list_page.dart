import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/design/widgets/app_button.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/writing_controllers.dart';

class WritingListPage extends ConsumerWidget {
  const WritingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writingListControllerProvider);
    final controller = ref.read(writingListControllerProvider.notifier);

    return AppPageScaffold(
      title: 'Writing practice',
      subtitle:
          'Pick a task, draft on-device, submit for AI grading, then revisit the result journey when scoring is ready.',
      paletteKey: AppPagePaletteKey.writing,
      trailing: AppHeaderIconAction(
        tooltip: 'History',
        icon: Icons.history_rounded,
        onPressed: () => context.go('/writing/history'),
      ),
      onRefresh: controller.refresh,
      children: [
        ...state.when(
          data: (value) => [
            AppCard(
              strong: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All types'),
                        selected: (value.query.taskType ?? '').isEmpty,
                        onSelected: (_) => controller.updateTaskType('ALL'),
                      ),
                      ...writingTaskTypeOptions.map(
                        (item) => ChoiceChip(
                          label: Text(item.replaceAll('_', ' ')),
                          selected: value.query.taskType == item,
                          onSelected: (_) => controller.updateTaskType(item),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All levels'),
                        selected: (value.query.difficulty ?? '').isEmpty,
                        onSelected: (_) => controller.updateDifficulty('ALL'),
                      ),
                      ...writingDifficultyOptions.map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: value.query.difficulty == item,
                          onSelected: (_) => controller.updateDifficulty(item),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!value.tasks.hasItems)
              const AppEmptyState(
                icon: Icons.edit_note_rounded,
                title: 'No writing tasks yet',
                subtitle:
                    'Try another filter or refresh once the backend has published tasks.',
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...value.tasks.items.map((task) {
                      final highestScore = value.highestScoreFor(task.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _WritingTaskTile(
                          taskTitle: task.title,
                          taskType: task.taskType,
                          difficulty: task.difficulty,
                          meta:
                              '${task.timeLimitMinutes} min • ${task.minWords}-${task.maxWords} words',
                          statusLabel: highestScore == null
                              ? 'Not attempted'
                              : highestScore.isPending
                              ? 'Pending grading'
                              : highestScore.highestBandScore == null
                              ? 'Attempted'
                              : 'Best band ${highestScore.highestBandScore!.toStringAsFixed(1)}',
                          onOpen: () => context.go('/writing/task/${task.id}'),
                          onResume: () =>
                              context.go('/writing/task/${task.id}/take'),
                          onBestResult: highestScore?.submissionId == null
                              ? null
                              : () => context.go(
                                  '/writing/submission/${highestScore!.submissionId}',
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
          error: (_, _) => [
            AppErrorCard(
              title: 'Writing tasks are unavailable',
              message:
                  'We could not load the phase-7 writing foundation right now.',
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
    required this.meta,
    required this.statusLabel,
    required this.onOpen,
    required this.onResume,
    this.onBestResult,
  });

  final String taskTitle;
  final String taskType;
  final String difficulty;
  final String meta;
  final String statusLabel;
  final VoidCallback onOpen;
  final VoidCallback onResume;
  final VoidCallback? onBestResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(taskTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('$taskType • $difficulty'),
          const SizedBox(height: 4),
          Text(meta),
          const SizedBox(height: 4),
          Text(statusLabel),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: 'Task detail',
                variant: AppButtonVariant.outline,
                onPressed: onOpen,
              ),
              AppButton(
                label: 'Write now',
                icon: Icons.edit_rounded,
                onPressed: onResume,
              ),
              if (onBestResult != null)
                AppButton(
                  label: 'Best result',
                  variant: AppButtonVariant.tonal,
                  onPressed: onBestResult,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
