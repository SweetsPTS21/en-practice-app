import 'package:enpractice/core/vocabulary_test/vocabulary_test_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('vocabulary test models', () {
    test('parses test detail payload', () {
      final detail = VocabularyTestDetail.fromJson({
        'testId': 'test-1',
        'title': 'Generated test',
        'status': 'READY',
        'questionCount': 5,
        'estimatedMinutes': 8,
        'selectedSources': ['VOCABULARY_RECORD'],
        'createdAt': '2026-04-03T09:00:00Z',
        'questions': [
          {
            'questionId': 'q1',
            'order': 1,
            'sourceWord': 'serene',
            'sourceType': 'USER_DICTIONARY',
            'questionText': 'Choose the best meaning.',
            'blankSentence': 'The lake was ____ at dawn.',
            'options': ['noisy', 'calm', 'crowded', 'dirty'],
          },
        ],
      });

      expect(detail.testId, 'test-1');
      expect(detail.status, VocabularyTestStatus.ready);
      expect(detail.questions.single.sourceWord, 'serene');
    });

    test('parses attempt result payload', () {
      final result = VocabularyTestAttemptResult.fromJson({
        'attemptId': 'attempt-1',
        'testId': 'test-1',
        'testTitle': 'Generated test',
        'totalQuestions': 5,
        'correctCount': 4,
        'accuracyPercent': 80,
        'status': 'COMPLETED',
        'results': [
          {
            'questionId': 'q1',
            'order': 1,
            'sourceWord': 'serene',
            'questionText': 'Choose the best meaning.',
            'blankSentence': 'The lake was ____ at dawn.',
            'options': ['noisy', 'calm', 'crowded', 'dirty'],
            'selectedOptionIndex': 1,
            'selectedAnswer': 'calm',
            'correctOptionIndex': 1,
            'correctAnswer': 'calm',
            'isCorrect': true,
          },
        ],
      });

      expect(result.isCompleted, isTrue);
      expect(result.results.single.correctAnswer, 'calm');
      expect(result.accuracyPercent, 80);
    });
  });
}
