import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/productive/paged_items.dart';
import '../../../core/speaking_conversation/speaking_conversation_models.dart';
import '../../../core/speaking_conversation/speaking_conversation_providers.dart';
import '../../../core/theme/page_palettes.dart';

final speakingConversationHistoryProvider =
    FutureProvider.autoDispose<PagedItems<SpeakingConversation>>((ref) {
      return ref.watch(speakingConversationApiProvider).getConversations();
    });

class SpeakingConversationHistoryPage extends ConsumerWidget {
  const SpeakingConversationHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(speakingConversationHistoryProvider);

    return AppPageScaffold(
      title: 'Conversation history',
      subtitle:
          'Review guided conversation attempts, grading states, and revisit paths.',
      paletteKey: AppPagePaletteKey.speaking,
      onRefresh: () async =>
          ref.invalidate(speakingConversationHistoryProvider),
      children: [
        switch (history) {
          AsyncData(:final value) when value.items.isEmpty => const AppEmptyState(
            icon: Icons.forum_outlined,
            title: 'No guided conversations yet',
            subtitle:
                'Start one from the speaking topic list to populate this history.',
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
                    title: Text(item.topicQuestion),
                    subtitle: Text('${item.topicPart} • ${item.status}'),
                    trailing: Text(
                      item.overallBandScore == null
                          ? 'Pending'
                          : item.overallBandScore!.toStringAsFixed(1),
                    ),
                    onTap: () =>
                        context.go('/speaking/conversation/result/${item.id}'),
                  ),
                ),
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Conversation history is unavailable',
            message: 'We could not load guided conversations.',
            onRetry: () => ref.invalidate(speakingConversationHistoryProvider),
          ),
          _ => const AppLoadingCard(
            height: 220,
            message: 'Loading guided conversations...',
          ),
        },
      ],
    );
  }
}
