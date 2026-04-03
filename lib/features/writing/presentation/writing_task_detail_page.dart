import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/writing_controllers.dart';

class WritingTaskDetailPage extends ConsumerWidget {
  const WritingTaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(writingTaskDetailProvider(taskId));
    final highestScore = ref.watch(writingTaskHighestScoreProvider(taskId));

    return AppPageScaffold(
      title: 'Writing task detail',
      subtitle:
          'Review the prompt, scoring constraints, and your latest status before you start writing.',
      paletteKey: AppPagePaletteKey.writing,
      onRefresh: () async {
        ref.invalidate(writingTaskDetailProvider(taskId));
        ref.invalidate(writingTaskHighestScoreProvider(taskId));
      },
      children: [
        switch (detail) {
          AsyncData(:final value) => AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text('${value.taskType} • ${value.difficulty}'),
                const SizedBox(height: 8),
                Text(
                  '${value.timeLimitMinutes} minutes • ${value.minWords}-${value.maxWords} words',
                ),
                const SizedBox(height: 18),
                if (value.content.trim().isNotEmpty) ...[
                  Text(
                    'Prompt',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(value.content),
                  const SizedBox(height: 16),
                ],
                if (value.instruction.trim().isNotEmpty) ...[
                  Text(
                    'Instruction',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(value.instruction),
                  const SizedBox(height: 16),
                ],
                switch (highestScore) {
                  AsyncData(:final value) when value != null => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      value.isPending
                          ? 'Latest attempt is still grading.'
                          : value.highestBandScore == null
                          ? 'You already attempted this task.'
                          : 'Best recorded band: ${value.highestBandScore!.toStringAsFixed(1)}',
                    ),
                  ),
                  _ => const SizedBox.shrink(),
                },
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppButton(
                      label: 'Start writing',
                      icon: Icons.edit_note_rounded,
                      onPressed: () => context.go('/writing/task/$taskId/take'),
                    ),
                    if (highestScore.valueOrNull?.submissionId != null)
                      AppButton(
                        label: 'Open best result',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.go(
                          '/writing/submission/${highestScore.valueOrNull!.submissionId}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Task detail is unavailable',
            message: 'We could not load this writing task.',
            onRetry: () => ref.invalidate(writingTaskDetailProvider(taskId)),
          ),
          _ => const AppLoadingCard(
            height: 280,
            message: 'Loading task detail...',
          ),
        },
      ],
    );
  }
}
