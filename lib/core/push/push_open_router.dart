import '../analytics/learning_analytics_service.dart';
import '../learning_journey/learning_journey_action_service.dart';
import 'push_message_models.dart';

class PushOpenRouter {
  PushOpenRouter({
    required LearningJourneyActionService learningJourneyActionService,
  }) : _learningJourneyActionService = learningJourneyActionService;

  final LearningJourneyActionService _learningJourneyActionService;

  Future<JourneyActionOutcome> prepareOpen(PushMessage message) {
    return _learningJourneyActionService.prepareAction(
      JourneyActionRequest(
        source: 'PUSH_NOTIFICATION',
        analyticsEvents: const [
          LearningEventName.notificationOpened,
          LearningEventName.notificationClicked,
        ],
        module: _resolveModule(message),
        actionUrl: message.actionUrl,
        referenceType: message.referenceType ?? 'USER_NOTIFICATION',
        referenceId: message.referenceId ?? message.id,
        defaultRoute: '/notifications',
        reason: message.reason,
        estimatedMinutes: message.estimatedMinutes,
        metadata: {
          ...message.metadata,
          'entryPoint': 'notification',
          'notificationId': message.id,
          'triggerType': message.triggerType,
          'deliveryChannel': 'PUSH',
        },
      ),
    );
  }

  String? _resolveModule(PushMessage message) {
    final rawModule = message.metadata['module']?.toString();
    if ((rawModule ?? '').isNotEmpty) {
      return rawModule;
    }

    final actionUrl = message.actionUrl?.toLowerCase() ?? '';
    if (actionUrl.contains('/ielts/')) {
      return 'IELTS';
    }
    if (actionUrl.contains('/writing/')) {
      return 'WRITING';
    }
    if (actionUrl.contains('/custom-speaking/')) {
      return 'CUSTOM_SPEAKING';
    }
    if (actionUrl.contains('/speaking/')) {
      return 'SPEAKING';
    }
    if (actionUrl.contains('/dictionary/')) {
      return 'VOCABULARY';
    }
    return message.type;
  }
}
