import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/custom_speaking/custom_speaking_models.dart';
import '../../../core/custom_speaking/custom_speaking_providers.dart';
import '../../../core/navigation/learning_launch_store.dart';
import '../../../core/network/api_error.dart';
import '../../../core/learning_journey/learning_journey_providers.dart';

class CustomSpeakingSetupState {
  const CustomSpeakingSetupState({
    required this.topic,
    required this.style,
    required this.personality,
    required this.expertise,
    required this.voiceName,
    required this.gradingEnabled,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String topic;
  final String style;
  final String personality;
  final String expertise;
  final String? voiceName;
  final bool gradingEnabled;
  final bool isSubmitting;
  final String? errorMessage;

  bool get canSubmit => topic.trim().isNotEmpty && !isSubmitting;

  CustomSpeakingSetupState copyWith({
    String? topic,
    String? style,
    String? personality,
    String? expertise,
    String? voiceName,
    bool clearVoiceName = false,
    bool? gradingEnabled,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CustomSpeakingSetupState(
      topic: topic ?? this.topic,
      style: style ?? this.style,
      personality: personality ?? this.personality,
      expertise: expertise ?? this.expertise,
      voiceName: clearVoiceName ? null : (voiceName ?? this.voiceName),
      gradingEnabled: gradingEnabled ?? this.gradingEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CustomSpeakingSetupController extends AutoDisposeNotifier<CustomSpeakingSetupState> {
  @override
  CustomSpeakingSetupState build() {
    return CustomSpeakingSetupState(
      topic: '',
      style: customSpeakingStyleOptions.first.value,
      personality: customSpeakingPersonalityOptions.first.value,
      expertise: customSpeakingExpertiseOptions.first.value,
      voiceName: customSpeakingVoiceOptions.first.value,
      gradingEnabled: true,
    );
  }

  void updateTopic(String value) {
    state = state.copyWith(topic: value, clearErrorMessage: true);
  }

  void selectStyle(String value) {
    state = state.copyWith(style: value, clearErrorMessage: true);
  }

  void selectPersonality(String value) {
    state = state.copyWith(personality: value, clearErrorMessage: true);
  }

  void selectExpertise(String value) {
    state = state.copyWith(expertise: value, clearErrorMessage: true);
  }

  void selectVoice(String? value) {
    state = state.copyWith(
      voiceName: value,
      clearVoiceName: value == null,
      clearErrorMessage: true,
    );
  }

  void setGradingEnabled(bool value) {
    state = state.copyWith(gradingEnabled: value, clearErrorMessage: true);
  }

  Future<CustomSpeakingChatBootstrap> startConversation() async {
    final topic = state.topic.trim();
    if (topic.isEmpty) {
      const error = ApiError(
        message: 'Enter a topic to start your speaking conversation.',
        status: 400,
      );
      state = state.copyWith(errorMessage: error.message);
      throw error;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      final step = await ref
          .read(customSpeakingApiProvider)
          .startConversation(
            StartCustomSpeakingPayload(
              topic: topic,
              style: state.style,
              personality: state.personality,
              expertise: state.expertise,
              voiceName: state.voiceName,
              gradingEnabled: state.gradingEnabled,
            ),
          );
      final bootstrap = CustomSpeakingChatBootstrap.fromStartStep(
        step: step,
        topic: topic,
      );
      final snapshotStore = ref.read(customConversationSnapshotStoreProvider);
      await snapshotStore.saveSnapshot(
        CustomConversationSnapshot(
          conversationId: bootstrap.conversationId,
          title: bootstrap.title,
          topic: bootstrap.topic,
          latestAiMessage: bootstrap.latestAiMessage,
          gradingEnabled: bootstrap.gradingEnabled,
          status: bootstrap.status,
          userTurnCount: bootstrap.userTurnCount,
          maxUserTurns: bootstrap.maxUserTurns,
          voiceName: bootstrap.voiceName,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      await ref.read(learningLaunchStoreProvider).rememberLearningLaunch(
        LearningLaunchContext(
          source: 'CUSTOM_SPEAKING_SETUP',
          module: 'SPEAKING',
          route: '/custom-speaking/conversation/${bootstrap.conversationId}',
          referenceType: 'CUSTOM_SPEAKING_CONVERSATION',
          referenceId: bootstrap.conversationId,
          taskTitle: bootstrap.title,
          reason: 'CUSTOM_SPEAKING_CONVERSATION',
          estimatedMinutes: 8,
          metadata: <String, dynamic>{
            'topic': bootstrap.topic,
            'gradingEnabled': bootstrap.gradingEnabled,
          },
          started: false,
          launchedAt: DateTime.now(),
        ),
      );
      state = state.copyWith(isSubmitting: false, clearErrorMessage: true);
      return bootstrap;
    } catch (error) {
      final message = error is ApiError ? error.message : error.toString();
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      rethrow;
    }
  }
}

final customSpeakingSetupControllerProvider =
    AutoDisposeNotifierProvider<CustomSpeakingSetupController, CustomSpeakingSetupState>(
      CustomSpeakingSetupController.new,
    );
