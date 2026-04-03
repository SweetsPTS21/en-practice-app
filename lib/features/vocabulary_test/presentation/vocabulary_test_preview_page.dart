import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/vocabulary_test/vocabulary_test_providers.dart';
import '../application/vocabulary_test_list_controller.dart';

class VocabularyTestPreviewPage extends ConsumerWidget {
  const VocabularyTestPreviewPage({super.key, required this.testId});

  final String testId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(vocabularyTestDetailProvider(testId));
    return AppPageScaffold(
      title: 'Vocabulary test preview',
      subtitle:
          'Preview the generated questions before starting a new attempt.',
      paletteKey: AppPagePaletteKey.vocabularyTest,
      onRefresh: () => ref.refresh(vocabularyTestDetailProvider(testId).future),
      children: [
        ...detail.when(
          data: (value) => [
            AppCard(
              strong: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${value.questionCount} questions • ${value.estimatedMinutes} min',
                  ),
                  if (value.selectedSources.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Sources: ${value.selectedSources.join(', ')}'),
                  ],
                ],
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...value.questions
                      .take(5)
                      .map(
                        (question) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${question.order}. ${question.questionText}',
                          ),
                        ),
                      ),
                ],
              ),
            ),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Generate again',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/vocabulary-tests'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Start test',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () async {
                        final response = await ref
                            .read(vocabularyTestApiProvider)
                            .startTest(testId);
                        if (context.mounted) {
                          context.push(
                            '/vocabulary-tests/attempts/${response.attemptId}',
                            extra: response,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          loading: () => const [
            AppCard(
              child: SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          error: (error, _) => [AppCard(child: Text(error.toString()))],
        ),
      ],
    );
  }
}
