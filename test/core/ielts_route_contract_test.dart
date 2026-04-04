import 'package:enpractice/core/ielts/ielts_models.dart';
import 'package:enpractice/core/navigation/app_route_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ielts route contract', () {
    test('normalizes IELTS result and resume aliases', () {
      expect(
        normalizeInternalRoute('/ielts/attempts/attempt-1')?.href,
        '/ielts/result/attempt-1',
      );
      expect(
        normalizeInternalRoute('/ielts/tests/test-1/resume')?.href,
        '/ielts/test/test-1',
      );
    });

    test('keeps quick launch routes as supported first-class routes', () {
      const route =
          '/ielts?mode=quick&skill=READING&testId=test-1&attemptMode=QUICK&scopeType=PASSAGE&scopeId=passage-3';

      expect(isSupportedAppRoute(route), isTrue);
      expect(isLearningSessionRoute('/ielts/take/attempt-1'), isTrue);
      expect(isReviewRoute('/ielts/result/attempt-1'), isTrue);
    });

    test('parses direct IELTS quick launch intent', () {
      final uri = Uri.parse(
        '/ielts?mode=quick&skill=LISTENING&testId=test-1&attemptMode=QUICK&scopeType=SECTION&scopeId=section-2',
      );

      final intent = IeltsLaunchIntent.fromUri(uri);

      expect(intent.hasDirectStart, isTrue);
      expect(intent.testId, 'test-1');
      expect(intent.skill, IeltsSkill.listening);
      expect(intent.attemptMode, IeltsAttemptMode.quick);
      expect(intent.scopeType, IeltsScopeType.section);
      expect(intent.scopeId, 'section-2');
    });
  });
}
