import 'package:enpractice/core/navigation/app_route_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app route contract', () {
    test('normalizes vocabulary aliases', () {
      expect(normalizeInternalRoute('/vocabulary')?.href, '/vocabulary-tests');
      expect(
        normalizeInternalRoute('/vocabulary/check')?.href,
        '/vocabulary/check',
      );
      expect(
        normalizeInternalRoute('/history')?.href,
        '/vocabulary-tests/history',
      );
      expect(normalizeInternalRoute('/review')?.href, '/dictionary/review');
    });

    test('recognizes new supported vocabulary routes', () {
      expect(isSupportedAppRoute('/vocabulary/check'), isTrue);
      expect(isSupportedAppRoute('/vocabulary-tests/abc123'), isTrue);
      expect(
        isLearningSessionRoute('/vocabulary-tests/attempts/attempt-1'),
        isTrue,
      );
    });

    test('normalizes productive skill aliases', () {
      expect(
        normalizeInternalRoute('/writing/tasks/task-1')?.href,
        '/writing/task/task-1',
      );
      expect(
        normalizeInternalRoute('/speaking/attempts/attempt-1')?.href,
        '/speaking/result/attempt-1',
      );
      expect(
        normalizeInternalRoute('/speaking/conversations/conversation-1')?.href,
        '/speaking/conversation/result/conversation-1',
      );
      expect(
        normalizeInternalRoute('/speaking/custom/conversation-1')?.href,
        '/custom-speaking/conversation/conversation-1',
      );
    });

    test('treats productive learning routes as first-class mobile routes', () {
      expect(isSupportedAppRoute('/writing/history'), isTrue);
      expect(isSupportedAppRoute('/speaking/conversation/history'), isTrue);
      expect(isSupportedAppRoute('/custom-speaking/history'), isTrue);
      expect(isLearningSessionRoute('/speaking/conversation/topic-1'), isTrue);
      expect(
        isReviewRoute('/speaking/conversation/result/conversation-1'),
        isTrue,
      );
    });
  });
}
