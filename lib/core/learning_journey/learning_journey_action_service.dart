import '../analytics/learning_analytics_service.dart';
import '../navigation/app_route_contract.dart';
import '../navigation/learning_action_resolver.dart';
import '../navigation/learning_launch_store.dart';
import 'result_action_models.dart';

class JourneyActionRequest {
  const JourneyActionRequest({
    required this.source,
    required this.analyticsEvents,
    this.module,
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    this.taskId,
    this.taskTitle,
    this.reason,
    this.estimatedMinutes,
    this.priority,
    this.defaultRoute = '/home',
    this.metadata = const <String, dynamic>{},
  });

  final String source;
  final List<LearningEventName> analyticsEvents;
  final String? module;
  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final String? taskId;
  final String? taskTitle;
  final String? reason;
  final int? estimatedMinutes;
  final int? priority;
  final String defaultRoute;
  final Map<String, dynamic> metadata;
}

class JourneyActionOutcome {
  const JourneyActionOutcome({
    required this.target,
    required this.isReviewRoute,
  });

  final LearningActionTarget target;
  final bool isReviewRoute;
}

class LearningJourneyActionService {
  LearningJourneyActionService({
    required LearningAnalyticsService analyticsService,
    required LearningLaunchStore launchStore,
  })  : _analyticsService = analyticsService,
        _launchStore = launchStore;

  final LearningAnalyticsService _analyticsService;
  final LearningLaunchStore _launchStore;

  Future<JourneyActionOutcome> prepareAction(
    JourneyActionRequest request,
  ) async {
    final target = resolveLearningActionTarget(
      LearningActionInput(
        actionUrl: request.actionUrl,
        referenceType: request.referenceType,
        referenceId: request.referenceId,
        module: request.module,
        metadata: request.metadata,
        defaultRoute: request.defaultRoute,
      ),
    );

    final reviewRoute = isReviewRoute(target.href);
    for (final eventName in request.analyticsEvents) {
      await _analyticsService.trackEvent(
        LearningEventPayload(
          eventName: eventName,
          source: request.source,
          module: request.module,
          route: target.href,
          referenceType: request.referenceType,
          referenceId: request.referenceId,
          metadata: {
            'taskId': request.taskId,
            'reason': request.reason,
            'estimatedMinutes': request.estimatedMinutes,
            'priority': request.priority,
            'usedFallback': target.usedFallback,
            'isReviewRoute': reviewRoute,
            ...request.metadata,
          },
        ),
      );
    }

    if (target.isLearningSession) {
      await _launchStore.rememberLearningLaunch(
        LearningLaunchContext(
          source: request.source,
          module: request.module,
          route: target.href,
          referenceType: request.referenceType,
          referenceId: request.referenceId,
          taskId: request.taskId,
          taskTitle: request.taskTitle,
          reason: request.reason,
          estimatedMinutes: request.estimatedMinutes,
          priority: request.priority,
          metadata: request.metadata,
          started: false,
          launchedAt: DateTime.now(),
        ),
      );
    }

    return JourneyActionOutcome(
      target: target,
      isReviewRoute: reviewRoute,
    );
  }

  Future<JourneyActionOutcome> prepareResultAction({
    required String source,
    required String module,
    required String resultReferenceType,
    required String resultReferenceId,
    required ResultNextAction action,
  }) {
    final eventName = switch (action.intent) {
      ResultActionIntent.review => LearningEventName.errorReviewOpened,
      ResultActionIntent.reviewAgain => LearningEventName.reviewAgainClicked,
      ResultActionIntent.nextStep => LearningEventName.resultNextActionClicked,
    };

    return prepareAction(
      JourneyActionRequest(
        source: source,
        analyticsEvents: [eventName],
        module: module,
        actionUrl: action.actionUrl,
        referenceType: action.referenceType ?? resultReferenceType,
        referenceId: action.referenceId ?? resultReferenceId,
        reason: action.reason,
        estimatedMinutes: action.estimatedMinutes,
        priority: action.priority,
        metadata: action.metadata,
      ),
    );
  }
}
