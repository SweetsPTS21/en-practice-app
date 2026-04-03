import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/writing_controllers.dart';

class WritingHistoryPage extends ConsumerWidget {
  const WritingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(writingSubmissionHistoryProvider);

    return AppPageScaffold(
      title: 'Writing history',
      subtitle:
          'Reopen previous submissions, check pending grading states, and jump back into improvement loops.',
      paletteKey: AppPagePaletteKey.writing,
      onRefresh: () async => ref.invalidate(writingSubmissionHistoryProvider),
      children: [
        switch (history) {
          AsyncData(:final value) when value.items.isEmpty => const AppEmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: 'No writing submissions yet',
            subtitle:
                'Your completed drafts will show up here once you submit them.',
          ),
          AsyncData(:final value) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent submissions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...value.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.taskTitle),
                    subtitle: Text(
                      '${item.taskType} • ${item.wordCount} words • ${item.status}',
                    ),
                    trailing: Text(
                      item.isPending || item.overallBandScore == null
                          ? 'Pending'
                          : item.overallBandScore!.toStringAsFixed(1),
                    ),
                    onTap: () => context.go('/writing/submission/${item.id}'),
                  ),
                ),
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Writing history is unavailable',
            message: 'We could not load your writing submissions.',
            onRetry: () => ref.invalidate(writingSubmissionHistoryProvider),
          ),
          _ => const AppLoadingCard(
            height: 220,
            message: 'Loading writing history...',
          ),
        },
      ],
    );
  }
}
