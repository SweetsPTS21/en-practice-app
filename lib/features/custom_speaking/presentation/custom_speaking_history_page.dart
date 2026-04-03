import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/custom_speaking/custom_speaking_providers.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/productive/paged_items.dart';
import '../../../core/theme/page_palettes.dart';

final customSpeakingHistoryProvider =
    FutureProvider.autoDispose<PagedItems<CustomSpeakingConversation>>((ref) {
      return ref.watch(customSpeakingApiProvider).getConversations();
    });

class CustomSpeakingHistoryPage extends ConsumerWidget {
  const CustomSpeakingHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(customSpeakingHistoryProvider);

    return AppPageScaffold(
      title: 'Custom speaking history',
      subtitle:
          'Resume in-progress custom conversations or reopen graded results from the same cluster.',
      paletteKey: AppPagePaletteKey.speaking,
      onRefresh: () async => ref.invalidate(customSpeakingHistoryProvider),
      children: [
        switch (history) {
          AsyncData(:final value) when value.items.isEmpty =>
            const AppEmptyState(
              icon: Icons.record_voice_over_outlined,
              title: 'No custom conversations yet',
              subtitle: 'Start a custom speaking session to see it here.',
            ),
          AsyncData(:final value) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent conversations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...value.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.title),
                    subtitle: Text('${item.topic} • ${item.status}'),
                    trailing: Text(
                      item.overallScore == null
                          ? 'Pending'
                          : item.overallScore!.toStringAsFixed(1),
                    ),
                    onTap: () => context.go(
                      item.status.toUpperCase() == 'IN_PROGRESS'
                          ? '/custom-speaking/conversation/${item.id}'
                          : '/custom-speaking/result/${item.id}',
                    ),
                  ),
                ),
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Custom speaking history is unavailable',
            message: 'We could not load custom speaking conversations.',
            onRetry: () => ref.invalidate(customSpeakingHistoryProvider),
          ),
          _ => const AppLoadingCard(
            height: 220,
            message: 'Loading custom speaking history...',
          ),
        },
      ],
    );
  }
}
