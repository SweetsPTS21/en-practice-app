import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/learning_analytics_service.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';
import '../../../core/navigation/learning_action_resolver.dart';
import '../../../core/navigation/learning_launch_store.dart';
import '../../../core/recommendation/recommendation_feedback_models.dart';
import '../../../core/recommendation/recommendation_api.dart';
import '../../../core/recommendation/recommendation_models.dart';
import '../../../core/recommendation/recommendation_providers.dart';
import '../../../core/recommendation/recommendation_route_bridge.dart';
import '../../../core/recommendation/recommendation_surface.dart';

class RecommendationFeedbackController {
  RecommendationFeedbackController({
    required RecommendationApi api,
    required LearningAnalyticsService analyticsService,
    required LearningLaunchStore launchStore,
  }) : _api = api,
       _analyticsService = analyticsService,
       _launchStore = launchStore;

  final RecommendationApi _api;
  final LearningAnalyticsService _analyticsService;
  final LearningLaunchStore _launchStore;

  Future<LearningActionTarget> click({
    required RecommendationCardModel recommendation,
    required RecommendationSurface surface,
    required String source,
    required String currentRoute,
    int position = 0,
  }) async {
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: recommendation.actionUrl,
        referenceType: recommendation.referenceType,
        referenceId: recommendation.referenceId,
        module: recommendation.type,
        metadata: recommendation.metadata,
      ),
    );

    await _api.submitFeedback(
      recommendation.recommendationKey,
      RecommendationFeedbackRequest(
        action: RecommendationFeedbackAction.click,
        sourceSurface: surface,
        route: currentRoute,
        metadata: {'component': source.toLowerCase(), 'position': position},
      ),
    );

    await _analyticsService.trackEvent(
      LearningEventPayload(
        eventName: LearningEventName.recommendationClicked,
        source: source,
        module: recommendation.type,
        route: target.href,
        referenceType: recommendation.referenceType ?? recommendation.type,
        referenceId:
            recommendation.referenceId ?? recommendation.recommendationKey,
        metadata: {
          'sourceSurface': surface.value,
          'sourceRecommendationKey': recommendation.recommendationKey,
          'position': position,
          'usedFallback': target.usedFallback,
        },
      ),
    );

    if (target.isLearningSession) {
      await _launchStore.rememberLearningLaunch(
        LearningLaunchContext(
          source: source,
          module: recommendation.type,
          route: target.href,
          referenceType: recommendation.referenceType ?? recommendation.type,
          referenceId:
              recommendation.referenceId ?? recommendation.recommendationKey,
          taskTitle: recommendation.title,
          reason: recommendation.explanation?.reasonCode ?? recommendation.type,
          estimatedMinutes: recommendation.estimatedMinutes,
          priority: recommendation.priority,
          metadata: {
            ...recommendation.metadata,
            'entryPoint': 'recommendation',
            'sourceSurface': surface.value,
            'sourceRecommendationKey': recommendation.recommendationKey,
            ...buildRecommendationLaunchMetadata(recommendation, target.href),
          },
          started: false,
          launchedAt: DateTime.now(),
        ),
      );
    }

    return target;
  }

  Future<void> dismiss({
    required RecommendationCardModel recommendation,
    required RecommendationSurface surface,
    required String currentRoute,
    required String source,
    int position = 0,
  }) {
    return _api.submitFeedback(
      recommendation.recommendationKey,
      RecommendationFeedbackRequest(
        action: RecommendationFeedbackAction.dismiss,
        sourceSurface: surface,
        route: currentRoute,
        metadata: {'component': source.toLowerCase(), 'position': position},
      ),
    );
  }

  Future<void> snooze({
    required RecommendationCardModel recommendation,
    required RecommendationSurface surface,
    required String currentRoute,
    required DateTime snoozeUntil,
    required String source,
    int position = 0,
  }) {
    return _api.submitFeedback(
      recommendation.recommendationKey,
      RecommendationFeedbackRequest(
        action: RecommendationFeedbackAction.snooze,
        sourceSurface: surface,
        route: currentRoute,
        snoozeUntil: snoozeUntil,
        metadata: {
          'component': source.toLowerCase(),
          'position': position,
          'snoozeUntil': snoozeUntil.toUtc().toIso8601String(),
        },
      ),
    );
  }
}

final recommendationFeedbackControllerProvider =
    Provider<RecommendationFeedbackController>((ref) {
      final api = ref.watch(recommendationApiProvider);
      final analyticsService = ref.watch(learningAnalyticsServiceProvider);
      final launchStore = ref.watch(learningLaunchStoreProvider);
      return RecommendationFeedbackController(
        api: api,
        analyticsService: analyticsService,
        launchStore: launchStore,
      );
    });
