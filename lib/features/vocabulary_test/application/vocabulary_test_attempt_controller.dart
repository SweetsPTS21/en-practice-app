import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/vocabulary_test/vocabulary_test_models.dart';
import '../../../core/vocabulary_test/vocabulary_test_providers.dart';

class VocabularyTestAttemptState {
  const VocabularyTestAttemptState({
    required this.attemptId,
    required this.detail,
    required this.answers,
    required this.startedAt,
    this.result,
    this.isSubmitting = false,
  });

  final String attemptId;
  final VocabularyTestDetail detail;
  final Map<String, int> answers;
  final DateTime startedAt;
  final VocabularyTestAttemptResult? result;
  final bool isSubmitting;

  int get answeredCount => answers.length;

  VocabularyTestAttemptState copyWith({
    Map<String, int>? answers,
    VocabularyTestAttemptResult? result,
    bool? isSubmitting,
  }) {
    return VocabularyTestAttemptState(
      attemptId: attemptId,
      detail: detail,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      result: result ?? this.result,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class VocabularyTestAttemptController
    extends
        AutoDisposeFamilyNotifier<
          VocabularyTestAttemptState,
          StartVocabularyTestResponse
        > {
  @override
  VocabularyTestAttemptState build(StartVocabularyTestResponse arg) {
    return VocabularyTestAttemptState(
      attemptId: arg.attemptId,
      detail: arg.testDetail,
      answers: const <String, int>{},
      startedAt: DateTime.now(),
    );
  }

  void selectAnswer(String questionId, int optionIndex) {
    final answers = Map<String, int>.from(state.answers)
      ..[questionId] = optionIndex;
    state = state.copyWith(answers: answers);
  }

  Future<VocabularyTestAttemptResult> submit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final duration = DateTime.now().difference(state.startedAt).inSeconds;
      final result = await ref
          .read(vocabularyTestApiProvider)
          .submitAttempt(
            state.attemptId,
            VocabularyTestSubmitPayload(
              timeSpentSeconds: duration,
              answers: state.answers.entries
                  .map(
                    (entry) => VocabularyTestSubmitAnswer(
                      questionId: entry.key,
                      selectedOptionIndex: entry.value,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
      state = state.copyWith(isSubmitting: false, result: result);
      return result;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}

final vocabularyTestAttemptControllerProvider =
    AutoDisposeNotifierProviderFamily<
      VocabularyTestAttemptController,
      VocabularyTestAttemptState,
      StartVocabularyTestResponse
    >(VocabularyTestAttemptController.new);
