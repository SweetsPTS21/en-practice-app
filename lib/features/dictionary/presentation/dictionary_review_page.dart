import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/design/widgets/app_state_widgets.dart';
import '../../../core/dictionary/review_models.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import '../../../core/theme/page_palettes.dart';
import '../application/dictionary_review_controller.dart';

class DictionaryReviewPage extends ConsumerWidget {
  const DictionaryReviewPage({
    super.key,
    required this.filter,
    required this.limit,
    required this.route,
  });

  final ReviewFilter filter;
  final int limit;
  final String route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      dictionaryReviewControllerProvider(
        DictionaryReviewArgs(filter: filter, limit: limit),
      ),
    );

    return AppPageScaffold(
      title: 'Dictionary review',
      subtitle:
          'Grade each due word quickly, then bridge into the shared result journey.',
      paletteKey: AppPagePaletteKey.dictionary,
      children: [
        ...state.when(
          data: (value) {
            final word = value.currentWord;
            if (value.words.isEmpty) {
              return [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You have no due words for this filter.'),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Back to dictionary',
                        onPressed: () => context.go('/dictionary'),
                      ),
                    ],
                  ),
                ),
              ];
            }

            if (value.isSubmitting) {
              return const [
                AppLoadingCard(
                  height: 160,
                  message: 'Finishing your review...',
                ),
              ];
            }

            if (word == null && value.session != null) {
              return [
                AppCard(
                  strong: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Review completed',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${value.correctCount} / ${value.words.length} correct',
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Open result',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () async {
                          await ref
                              .read(learningAnalyticsServiceProvider)
                              .registerLearningCompletion(
                                route: route,
                                xpEarned: value.correctCount * 2,
                                metadata: {
                                  'completedWordCount': value.words.length,
                                },
                              );
                          if (context.mounted) {
                            context.go(
                              '/dictionary/review/result/${value.session!.sessionId}',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ];
            }

            return [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Queue'),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: value.progress),
                    const SizedBox(height: 10),
                    Text('${value.answeredCount + 1} / ${value.words.length}'),
                  ],
                ),
              ),
              AppCard(
                strong: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word!.word,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(word.meaning),
                    if (word.alternatives.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Alternatives: ${word.alternatives.join(', ')}'),
                    ],
                    if (word.explanation.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(word.explanation),
                    ],
                  ],
                ),
              ),
              AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Needs review',
                        variant: AppButtonVariant.outline,
                        onPressed: value.isSubmitting
                            ? null
                            : () => _answer(context, ref, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Got it',
                        icon: Icons.check_rounded,
                        onPressed: value.isSubmitting
                            ? null
                            : () => _answer(context, ref, true),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          loading: () => const [
            AppCard(
              child: SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (error, _) => [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Review session could not be loaded.'),
                  const SizedBox(height: 8),
                  Text(error.toString()),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _answer(
    BuildContext context,
    WidgetRef ref,
    bool isCorrect,
  ) async {
    final summary = await ref
        .read(
          dictionaryReviewControllerProvider(
            DictionaryReviewArgs(filter: filter, limit: limit),
          ).notifier,
        )
        .answerCurrent(isCorrect);
    if (summary == null) {
      return;
    }

    await ref
        .read(learningAnalyticsServiceProvider)
        .registerLearningStartIfNeeded(route);
  }
}
