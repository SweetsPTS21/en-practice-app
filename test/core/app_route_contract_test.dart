import 'package:enpractice/core/navigation/app_route_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app route contract', () {
    test('normalizes vocabulary aliases', () {
      expect(normalizeInternalRoute('/vocabulary')?.href, '/vocabulary-tests');
      expect(normalizeInternalRoute('/vocabulary/check')?.href, '/vocabulary/check');
      expect(normalizeInternalRoute('/history')?.href, '/vocabulary-tests/history');
      expect(normalizeInternalRoute('/review')?.href, '/dictionary/review');
    });

    test('recognizes new supported vocabulary routes', () {
      expect(isSupportedAppRoute('/vocabulary/check'), isTrue);
      expect(isSupportedAppRoute('/vocabulary-tests/abc123'), isTrue);
      expect(isLearningSessionRoute('/vocabulary-tests/attempts/attempt-1'), isTrue);
    });
  });
}
