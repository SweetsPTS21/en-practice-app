import 'package:dio/dio.dart';

import '../navigation/app_route_contract.dart';
import '../navigation/learning_launch_store.dart';

enum LearningEventName {
  homeOpened('HOME_OPENED'),
  continueLearningClicked('CONTINUE_LEARNING_CLICKED'),
  dailyTaskClicked('DAILY_TASK_CLICKED'),
  dailyTaskCompleted('DAILY_TASK_COMPLETED'),
  learningStarted('LEARNING_STARTED'),
  learningCompleted('LEARNING_COMPLETED'),
  learningAbandoned('LEARNING_ABANDONED'),
  resumeStarted('RESUME_STARTED'),
  recommendationClicked('RECOMMENDATION_CLICKED'),
  recommendationCompleted('RECOMMENDATION_COMPLETED'),
  speakingPromptStarted('SPEAKING_PROMPT_STARTED'),
  speakingPromptCompleted('SPEAKING_PROMPT_COMPLETED'),
  vocabMicroSessionStarted('VOCAB_MICRO_SESSION_STARTED'),
  vocabMicroSessionCompleted('VOCAB_MICRO_SESSION_COMPLETED'),
  notificationToSessionStarted('NOTIFICATION_TO_SESSION_STARTED'),
  resultNextActionClicked('RESULT_NEXT_ACTION_CLICKED'),
  errorReviewOpened('ERROR_REVIEW_OPENED'),
  reviewAgainClicked('REVIEW_AGAIN_CLICKED'),
  notificationOpened('NOTIFICATION_OPENED'),
  notificationClicked('NOTIFICATION_CLICKED'),
  reminderBannerClicked('REMINDER_BANNER_CLICKED');

  const LearningEventName(this.value);

  final String value;
}

class LearningEventPayload {
  const LearningEventPayload({
    required this.eventName,
    required this.source,
    this.module,
    this.route,
    this.referenceType,
    this.referenceId,
    this.sessionId,
    this.metadata,
  });

  final LearningEventName eventName;
  final String source;
  final String? module;
  final String? route;
  final String? referenceType;
  final String? referenceId;
  final String? sessionId;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName.value,
      'source': source,
      'module': module,
      'route': route,
      'referenceType': referenceType,
      'referenceId': referenceId,
      'sessionId': sessionId,
      'metadata': sanitizeMetadata(metadata),
    };
  }
}

class LearningAnalyticsService {
  LearningAnalyticsService({
    required Dio client,
    required LearningLaunchStore launchStore,
  }) : _client = client,
       _launchStore = launchStore;

  final Dio _client;
  final LearningLaunchStore _launchStore;

  Future<void> trackEvent(LearningEventPayload payload) async {
    try {
      await _client.post<Object?>(
        '/user/analytics/learning-events',
        data: payload.toJson(),
      );
    } catch (_) {
      // Analytics should never block product flow.
    }
  }

  Future<LearningLaunchContext?> registerLearningStartIfNeeded(
    String route,
  ) async {
    final normalizedRoute = normalizeInternalRoute(route)?.href ?? route;
    final launchContext = await _launchStore.consumeLearningStartForRoute(
      normalizedRoute,
      routesMatch,
    );
    if (launchContext == null || !isLearningSessionRoute(normalizedRoute)) {
      return null;
    }

    await trackEvent(
      LearningEventPayload(
        eventName: LearningEventName.learningStarted,
        source: launchContext.source,
        module: launchContext.module,
        route: normalizedRoute,
        referenceType: launchContext.referenceType,
        referenceId: launchContext.referenceId,
        metadata: {
          'reason': launchContext.reason,
          'estimatedMinutes': launchContext.estimatedMinutes,
          ...?launchContext.metadata,
        },
      ),
    );

    if (launchContext.metadata?['entryPoint'] == 'notification') {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.notificationToSessionStarted,
          source: launchContext.source,
          module: launchContext.module,
          route: normalizedRoute,
          referenceType: 'USER_NOTIFICATION',
          referenceId: launchContext.metadata?['notificationId']?.toString(),
          metadata: {
            'reason': launchContext.reason,
            'triggerType': launchContext.metadata?['triggerType'],
            'estimatedMinutes': launchContext.estimatedMinutes,
          },
        ),
      );
    }

    if (launchContext.metadata?['specialEvent'] == 'SPEAKING_PROMPT') {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.speakingPromptStarted,
          source: launchContext.source,
          module: 'SPEAKING',
          route: normalizedRoute,
          referenceType: launchContext.referenceType ?? 'DAILY_SPEAKING_PROMPT',
          referenceId: launchContext.referenceId,
          metadata: {'resumeState': launchContext.metadata?['resumeState']},
        ),
      );
    }

    if (launchContext.metadata?['specialEvent'] == 'VOCAB_MICRO_SESSION') {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.vocabMicroSessionStarted,
          source: launchContext.source,
          module: 'VOCAB',
          route: normalizedRoute,
          referenceType: launchContext.referenceType ?? 'VOCAB_MICRO_SESSION',
          referenceId: launchContext.referenceId,
          metadata: {
            'targetWordCount': launchContext.metadata?['targetWordCount'],
          },
        ),
      );
    }

    return launchContext;
  }

  Future<LearningLaunchContext?> registerLearningCompletion({
    required String route,
    int? xpEarned,
    Map<String, dynamic>? metadata,
  }) async {
    final normalizedRoute = normalizeInternalRoute(route)?.href ?? route;
    final pendingLaunch = _launchStore.getPendingLearningLaunch();
    final launchContext = await _launchStore.registerLearningCompletion(
      route: normalizedRoute,
      xpEarned: xpEarned,
      metadata: metadata,
    );

    final effectiveContext = launchContext ?? pendingLaunch;
    if (effectiveContext == null) {
      return null;
    }

    await trackEvent(
      LearningEventPayload(
        eventName: LearningEventName.learningCompleted,
        source: effectiveContext.source,
        module: effectiveContext.module,
        route: normalizedRoute,
        referenceType: effectiveContext.referenceType,
        referenceId: effectiveContext.referenceId,
        metadata: {
          'taskId': effectiveContext.taskId,
          'estimatedMinutes': effectiveContext.estimatedMinutes,
          'xpEarned': xpEarned,
          ...?effectiveContext.metadata,
          ...?metadata,
        },
      ),
    );

    if (effectiveContext.taskId != null &&
        effectiveContext.taskId!.isNotEmpty) {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.dailyTaskCompleted,
          source: effectiveContext.source,
          module: effectiveContext.module,
          route: normalizedRoute,
          referenceType: effectiveContext.referenceType ?? 'DAILY_PLAN_ITEM',
          referenceId: effectiveContext.referenceId,
          metadata: {
            'taskId': effectiveContext.taskId,
            'reason': effectiveContext.reason,
            'estimatedMinutes': effectiveContext.estimatedMinutes,
            'xpEarned': xpEarned,
          },
        ),
      );
    }

    if (effectiveContext.metadata?['entryPoint'] == 'recommendation') {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.recommendationCompleted,
          source: effectiveContext.source,
          module: effectiveContext.module,
          route: normalizedRoute,
          referenceType: effectiveContext.referenceType,
          referenceId: effectiveContext.referenceId,
          metadata: {
            'sourceSurface': effectiveContext.metadata?['sourceSurface'],
            'sourceRecommendationKey':
                effectiveContext.metadata?['sourceRecommendationKey'],
            'xpEarned': xpEarned,
            ...?metadata,
          },
        ),
      );
    }

    if (effectiveContext.metadata?['specialEvent'] == 'SPEAKING_PROMPT') {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.speakingPromptCompleted,
          source: effectiveContext.source,
          module: 'SPEAKING',
          route: normalizedRoute,
          referenceType:
              effectiveContext.referenceType ?? 'DAILY_SPEAKING_PROMPT',
          referenceId: effectiveContext.referenceId,
          metadata: {'resumeState': effectiveContext.metadata?['resumeState']},
        ),
      );
    }

    if (effectiveContext.metadata?['specialEvent'] == 'VOCAB_MICRO_SESSION') {
      await trackEvent(
        LearningEventPayload(
          eventName: LearningEventName.vocabMicroSessionCompleted,
          source: effectiveContext.source,
          module: 'VOCAB',
          route: normalizedRoute,
          referenceType:
              effectiveContext.referenceType ?? 'VOCAB_MICRO_SESSION',
          referenceId: effectiveContext.referenceId,
          metadata: {
            'targetWordCount': effectiveContext.metadata?['targetWordCount'],
            'completedWordCount':
                metadata?['completedWordCount'] ??
                effectiveContext.metadata?['targetWordCount'],
          },
        ),
      );
    }

    return effectiveContext;
  }

  Future<void> registerLearningAbandoned({required String route}) async {
    final pendingLaunch = _launchStore.getPendingLearningLaunch();
    if (pendingLaunch == null || !pendingLaunch.started) {
      return;
    }

    await trackEvent(
      LearningEventPayload(
        eventName: LearningEventName.learningAbandoned,
        source: pendingLaunch.source,
        module: pendingLaunch.module,
        route: normalizeInternalRoute(route)?.href ?? route,
        referenceType: pendingLaunch.referenceType,
        referenceId: pendingLaunch.referenceId,
        metadata: {
          'taskId': pendingLaunch.taskId,
          'reason': pendingLaunch.reason,
          'estimatedMinutes': pendingLaunch.estimatedMinutes,
        },
      ),
    );
    await _launchStore.clearPendingLearningLaunch();
  }
}
