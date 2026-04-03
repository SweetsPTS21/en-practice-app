import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/widgets/app_button.dart';
import '../../../core/design/widgets/app_card.dart';
import '../../../core/design/widgets/app_page_scaffold.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/vocabulary_test/vocabulary_test_models.dart';
import '../application/vocabulary_test_attempt_controller.dart';
import '../application/vocabulary_test_list_controller.dart';

class VocabularyTestAttemptPage extends ConsumerWidget {
  const VocabularyTestAttemptPage({
    super.key,
    required this.attemptId,
    this.startResponse,
  });

  final String attemptId;
  final StartVocabularyTestResponse? startResponse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (startResponse == null) {
      final detail = ref.watch(vocabularyTestAttemptDetailProvider(attemptId));
      return AppPageScaffold(
        title: 'Vocabulary test result',
        subtitle: 'Review a completed attempt from history.',
        paletteKey: AppPagePaletteKey.vocabularyTest,
        children: [
          ...detail.when(
            data: (value) => _buildResultCards(context, value),
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

    final state = ref.watch(vocabularyTestAttemptControllerProvider(startResponse!));
    final controller = ref.read(vocabularyTestAttemptControllerProvider(startResponse!).notifier);
    final result = state.result;
    if (result != null) {
      return AppPageScaffold(
        title: 'Vocabulary test result',
        subtitle: 'Accuracy is the primary metric, with question-by-question review below.',
        paletteKey: AppPagePaletteKey.vocabularyTest,
        children: _buildResultCards(context, result),
      );
    }

    return AppPageScaffold(
      title: startResponse!.testDetail.title,
      subtitle: 'Answer each generated question, then submit the attempt for scoring.',
      paletteKey: AppPagePaletteKey.vocabularyTest,
      children: [
        AppCard(
          child: Text('${state.answeredCount} / ${state.detail.questions.length} answered'),
        ),
        ...state.detail.questions.map(
          (question) => AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${question.order}. ${question.questionText}'),
                const SizedBox(height: 8),
                RadioGroup<int>(
                  groupValue: state.answers[question.questionId],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectAnswer(question.questionId, value);
                    }
                  },
                  child: Column(
                    children: List.generate(
                      question.options.length,
                      (index) => RadioListTile<int>(
                        value: index,
                        title: Text(question.options[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppCard(
          child: AppButton(
            label: state.isSubmitting ? 'Submitting...' : 'Submit test',
            icon: Icons.task_alt_rounded,
            onPressed: state.isSubmitting ? null : controller.submit,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildResultCards(BuildContext context, VocabularyTestAttemptResult result) {
    return [
      AppCard(
        strong: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${result.accuracyPercent.round()}%', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text('${result.correctCount} / ${result.totalQuestions} correct'),
          ],
        ),
      ),
      ...result.results.map(
        (item) => AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.order}. ${item.questionText}'),
              const SizedBox(height: 8),
              Text('Your answer: ${item.selectedAnswer ?? 'Skipped'}'),
              Text('Correct answer: ${item.correctAnswer}'),
              if (item.explanation != null && item.explanation!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.explanation!),
              ],
            ],
          ),
        ),
      ),
    ];
  }
}
