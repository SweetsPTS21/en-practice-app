import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_header_icon_action.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/speaking_controllers.dart';

class SpeakingListPage extends ConsumerWidget {
  const SpeakingListPage({super.key, this.mode});

  final String? mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(speakingListControllerProvider);
    final controller = ref.read(speakingListControllerProvider.notifier);

    return AppPageScaffold(
      title: 'Speaking practice',
      subtitle:
          'Train single-attempt speaking, jump into guided conversation, or branch into custom speaking without leaving the mobile productive loop.',
      paletteKey: AppPagePaletteKey.speaking,
      trailing: AppHeaderIconAction(
        tooltip: 'History',
        icon: Icons.history_rounded,
        onPressed: () => context.go('/speaking/history'),
      ),
      onRefresh: controller.refresh,
      children: [
        if ((mode ?? '').isNotEmpty)
          AppCard(
            strong: true,
            child: Text(
              mode == 'daily'
                  ? 'Daily prompt mode is active. Start a fast speaking attempt or a guided conversation from one of the topics below.'
                  : 'Quick practice mode is active. Pick the fastest route that gets you speaking right now.',
            ),
          ),
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
                        label: const Text('All parts'),
                        selected: (value.query.part ?? '').isEmpty,
                        onSelected: (_) => controller.updatePart('ALL'),
                      ),
                      ...speakingPartOptions.map(
                        (item) => ChoiceChip(
                          label: Text(item.replaceAll('_', ' ')),
                          selected: value.query.part == item,
                          onSelected: (_) => controller.updatePart(item),
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
                      ...speakingDifficultyOptions.map(
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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'More ways to practice',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Custom speaking conversation'),
                    subtitle: const Text(
                      'Start a freestyle AI conversation with a chosen style and personality.',
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () => context.go('/custom-speaking'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Guided conversation history'),
                    subtitle: const Text(
                      'Review graded conversation loops and reopen recent attempts.',
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () => context.go('/speaking/conversation/history'),
                  ),
                ],
              ),
            ),
            if (!value.topics.hasItems)
              const AppEmptyState(
                icon: Icons.mic_none_rounded,
                title: 'No speaking topics yet',
                subtitle:
                    'Refresh again after the backend publishes speaking prompts.',
              )
            else
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topic bank',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...value.topics.items.map((topic) {
                      final highest = value.highestScoreFor(topic.id);
                      final scoreLabel = highest == null
                          ? 'Not attempted'
                          : highest.highestBandScore == null
                          ? 'Attempted'
                          : 'Best band ${highest.highestBandScore!.toStringAsFixed(1)}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SpeakingTopicTile(
                          title: topic.question,
                          subtitle: '${topic.part} • ${topic.difficulty}',
                          scoreLabel: scoreLabel,
                          onPractice: () =>
                              context.go('/speaking/practice/${topic.id}'),
                          onConversation: () =>
                              context.go('/speaking/conversation/${topic.id}'),
                          onBestResult: highest?.attemptId == null
                              ? null
                              : () => context.go(
                                  '/speaking/result/${highest!.attemptId}',
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
              title: 'Speaking topics are unavailable',
              message: 'We could not load the speaking phase-7 surfaces.',
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

class _SpeakingTopicTile extends StatelessWidget {
  const _SpeakingTopicTile({
    required this.title,
    required this.subtitle,
    required this.scoreLabel,
    required this.onPractice,
    required this.onConversation,
    this.onBestResult,
  });

  final String title;
  final String subtitle;
  final String scoreLabel;
  final VoidCallback onPractice;
  final VoidCallback onConversation;
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
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 4),
          Text(scoreLabel),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: 'Single attempt',
                icon: Icons.mic_rounded,
                onPressed: onPractice,
              ),
              AppButton(
                label: 'Guided conversation',
                variant: AppButtonVariant.outline,
                onPressed: onConversation,
              ),
              if (onBestResult != null)
                AppButton(
                  label: 'Latest result',
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
