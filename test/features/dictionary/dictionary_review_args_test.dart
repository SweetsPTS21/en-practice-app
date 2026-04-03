import 'package:flutter_test/flutter_test.dart';

import 'package:enpractice/core/dictionary/review_models.dart';
import 'package:enpractice/features/dictionary/application/dictionary_review_controller.dart';

void main() {
  test('DictionaryReviewArgs compares by filter and limit', () {
    const left = DictionaryReviewArgs(filter: ReviewFilter.today, limit: 20);
    const right = DictionaryReviewArgs(filter: ReviewFilter.today, limit: 20);
    const different = DictionaryReviewArgs(
      filter: ReviewFilter.week,
      limit: 20,
    );

    expect(left, right);
    expect(left.hashCode, right.hashCode);
    expect(left == different, isFalse);
  });

  test(
    'DictionaryReviewState reports completion when current index reaches the end',
    () {
      const state = DictionaryReviewState(
        filter: ReviewFilter.today,
        limit: 20,
        counts: ReviewCounts(today: 1, week: 1, month: 1, wrong: 0, all: 1),
        words: [
          ReviewWord(
            id: 'w1',
            word: 'resilient',
            meaning: 'kien cuong',
            alternatives: [],
            examples: [],
            wordType: 'ADJ',
            ipa: '',
            explanation: '',
          ),
        ],
        answers: {'resilient': true},
        currentIndex: 1,
        isSubmitting: false,
        isCompleted: true,
      );

      expect(state.currentWord, isNull);
      expect(state.answeredCount, 1);
      expect(state.progress, 1);
    },
  );
}
