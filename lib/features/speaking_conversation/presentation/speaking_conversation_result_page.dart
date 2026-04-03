import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/speaking_conversation/speaking_conversation_models.dart';
import '../../../core/speaking_conversation/speaking_conversation_providers.dart';
import '../../../core/theme/page_palettes.dart';

final speakingConversationDetailProvider = FutureProvider.autoDispose
    .family<SpeakingConversation, String>((ref, conversationId) {
      return ref
          .watch(speakingConversationApiProvider)
          .getConversation(conversationId);
    });

class SpeakingConversationResultPage extends ConsumerWidget {
  const SpeakingConversationResultPage({
    super.key,
    required this.conversationId,
  });

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(
      speakingConversationDetailProvider(conversationId),
    );

    return AppPageScaffold(
      title: 'Conversation result',
      subtitle:
          'Guided conversation uses its own revisit page because grading lands on the conversation detail contract.',
      paletteKey: AppPagePaletteKey.speaking,
      onRefresh: () async =>
          ref.invalidate(speakingConversationDetailProvider(conversationId)),
      children: [
        switch (conversation) {
          AsyncData(:final value) => AppCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.topicQuestion,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${value.topicPart} • ${value.status}'),
                const SizedBox(height: 14),
                if (value.overallBandScore != null)
                  Text(
                    'Overall band ${value.overallBandScore!.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                else
                  const Text(
                    'This conversation is still being graded. Refresh or reopen from notification later.',
                  ),
                if ((value.aiFeedback ?? '').isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(value.aiFeedback!),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppButton(
                      label: 'Back to speaking',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/speaking'),
                    ),
                    AppButton(
                      label: 'Conversation history',
                      onPressed: () =>
                          context.go('/speaking/conversation/history'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AsyncError() => AppErrorCard(
            title: 'Conversation result is unavailable',
            message: 'We could not load this guided conversation.',
            onRetry: () => ref.invalidate(
              speakingConversationDetailProvider(conversationId),
            ),
          ),
          _ => const AppLoadingCard(
            height: 240,
            message: 'Loading conversation result...',
          ),
        },
        if (conversation.hasValue)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversation turns',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...conversation.value!.turns.map(
                  (turn) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI (${turn.turnType}): ${turn.aiQuestion}'),
                        const SizedBox(height: 6),
                        Text(
                          'You: ${turn.userTranscript ?? 'Waiting for answer'}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
