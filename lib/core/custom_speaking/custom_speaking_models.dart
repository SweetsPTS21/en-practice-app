import '../productive/paged_items.dart';
import '../speaking/speech_analytics_models.dart';

class CustomSpeakingOption {
  const CustomSpeakingOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;
}

class CustomSpeakingVoiceOption {
  const CustomSpeakingVoiceOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String? value;
  final String label;
  final String description;
}

const customSpeakingStyleOptions = <CustomSpeakingOption>[
  CustomSpeakingOption(
    value: 'CASUAL',
    label: 'Casual',
    description: 'Relaxed and everyday conversation practice.',
  ),
  CustomSpeakingOption(
    value: 'PROFESSIONAL',
    label: 'Professional',
    description: 'Clear, workplace-friendly responses with structure.',
  ),
  CustomSpeakingOption(
    value: 'ENCOURAGING',
    label: 'Encouraging',
    description: 'Supportive prompts that keep you speaking confidently.',
  ),
  CustomSpeakingOption(
    value: 'CHALLENGING',
    label: 'Challenging',
    description: 'Tighter follow-up questions for deeper speaking practice.',
  ),
];

const customSpeakingPersonalityOptions = <CustomSpeakingOption>[
  CustomSpeakingOption(
    value: 'FRIENDLY',
    label: 'Friendly',
    description: 'Warm and easy to respond to.',
  ),
  CustomSpeakingOption(
    value: 'HUMOROUS',
    label: 'Humorous',
    description: 'Light and playful without losing focus.',
  ),
  CustomSpeakingOption(
    value: 'PATIENT',
    label: 'Patient',
    description: 'Steady pacing that gives you room to elaborate.',
  ),
  CustomSpeakingOption(
    value: 'STRAIGHTFORWARD',
    label: 'Straightforward',
    description: 'Direct and concise prompts.',
  ),
];

const customSpeakingExpertiseOptions = <CustomSpeakingOption>[
  CustomSpeakingOption(
    value: 'GENERAL',
    label: 'General',
    description: 'Everyday topics that fit most speaking sessions.',
  ),
  CustomSpeakingOption(
    value: 'BUSINESS',
    label: 'Business',
    description: 'Work, meetings, clients, and professional situations.',
  ),
  CustomSpeakingOption(
    value: 'TECHNOLOGY',
    label: 'Technology',
    description: 'Digital tools, AI, products, and modern habits.',
  ),
  CustomSpeakingOption(
    value: 'EDUCATION',
    label: 'Education',
    description: 'Learning, school, teaching, and study routines.',
  ),
  CustomSpeakingOption(
    value: 'TRAVEL',
    label: 'Travel',
    description: 'Trips, tourism, transport, and cultural experiences.',
  ),
];

const customSpeakingVoiceOptions = <CustomSpeakingVoiceOption>[
  CustomSpeakingVoiceOption(
    value: null,
    label: 'Default voice',
    description: 'Let the server choose the default speaking voice.',
  ),
  CustomSpeakingVoiceOption(
    value: 'US_NEURAL_J',
    label: 'Voice J',
    description: 'Balanced US English voice.',
  ),
  CustomSpeakingVoiceOption(
    value: 'US_NEURAL_I',
    label: 'Voice I',
    description: 'Calm US English voice.',
  ),
  CustomSpeakingVoiceOption(
    value: 'US_NEURAL_F',
    label: 'Voice F',
    description: 'Clear US English voice.',
  ),
];

const customSpeakingLockedStatuses = <String>{
  'COMPLETED',
  'GRADING',
  'GRADED',
  'FAILED',
};

bool isCustomSpeakingLockedStatus(String status) {
  return customSpeakingLockedStatuses.contains(status.toUpperCase().trim());
}

enum ConversationMessageRole { ai, user, system }

enum CustomSpeakingRealtimeEventType {
  aiMessage,
  conversationComplete,
  error,
  unknown,
}

class CustomSpeakingConversationSummary {
  const CustomSpeakingConversationSummary({
    required this.conversationId,
    required this.title,
    required this.topic,
    required this.gradingEnabled,
    required this.status,
    required this.userTurnCount,
    required this.maxUserTurns,
    this.voiceName,
  });

  final String conversationId;
  final String title;
  final String topic;
  final bool gradingEnabled;
  final String status;
  final int userTurnCount;
  final int maxUserTurns;
  final String? voiceName;

  bool get isLocked => isCustomSpeakingLockedStatus(status);

  CustomSpeakingConversationSummary copyWith({
    String? conversationId,
    String? title,
    String? topic,
    bool? gradingEnabled,
    String? status,
    int? userTurnCount,
    int? maxUserTurns,
    String? voiceName,
    bool clearVoiceName = false,
  }) {
    return CustomSpeakingConversationSummary(
      conversationId: conversationId ?? this.conversationId,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      gradingEnabled: gradingEnabled ?? this.gradingEnabled,
      status: status ?? this.status,
      userTurnCount: userTurnCount ?? this.userTurnCount,
      maxUserTurns: maxUserTurns ?? this.maxUserTurns,
      voiceName: clearVoiceName ? null : (voiceName ?? this.voiceName),
    );
  }

  factory CustomSpeakingConversationSummary.fromConversation(
    CustomSpeakingConversation conversation,
  ) {
    return CustomSpeakingConversationSummary(
      conversationId: conversation.id,
      title: conversation.title,
      topic: conversation.topic,
      gradingEnabled: conversation.gradingEnabled,
      status: conversation.status,
      userTurnCount: conversation.userTurnCount,
      maxUserTurns: conversation.maxUserTurns,
      voiceName: conversation.voiceName,
    );
  }

  factory CustomSpeakingConversationSummary.fromSnapshot(
    CustomConversationSnapshot snapshot,
  ) {
    return CustomSpeakingConversationSummary(
      conversationId: snapshot.conversationId,
      title: snapshot.title,
      topic: snapshot.topic,
      gradingEnabled: snapshot.gradingEnabled,
      status: snapshot.status,
      userTurnCount: snapshot.userTurnCount,
      maxUserTurns: snapshot.maxUserTurns,
      voiceName: snapshot.voiceName,
    );
  }
}

class ConversationMessageItem {
  const ConversationMessageItem({
    required this.id,
    required this.role,
    required this.text,
    this.turnNumber,
    this.turnType,
    this.speechAnalytics,
    this.timeSpentSeconds,
    this.createdAt,
    this.isPendingSync = false,
  });

  final String id;
  final ConversationMessageRole role;
  final String text;
  final int? turnNumber;
  final String? turnType;
  final SpeechAnalytics? speechAnalytics;
  final int? timeSpentSeconds;
  final DateTime? createdAt;
  final bool isPendingSync;

  ConversationMessageItem copyWith({
    String? id,
    ConversationMessageRole? role,
    String? text,
    int? turnNumber,
    String? turnType,
    SpeechAnalytics? speechAnalytics,
    int? timeSpentSeconds,
    DateTime? createdAt,
    bool? isPendingSync,
  }) {
    return ConversationMessageItem(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      turnNumber: turnNumber ?? this.turnNumber,
      turnType: turnType ?? this.turnType,
      speechAnalytics: speechAnalytics ?? this.speechAnalytics,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      createdAt: createdAt ?? this.createdAt,
      isPendingSync: isPendingSync ?? this.isPendingSync,
    );
  }
}

class CustomSpeakingChatBootstrap {
  const CustomSpeakingChatBootstrap({
    required this.conversationId,
    required this.title,
    required this.topic,
    required this.gradingEnabled,
    required this.status,
    required this.userTurnCount,
    required this.maxUserTurns,
    this.latestAiMessage,
    this.voiceName,
  });

  final String conversationId;
  final String title;
  final String topic;
  final String? latestAiMessage;
  final bool gradingEnabled;
  final String status;
  final int userTurnCount;
  final int maxUserTurns;
  final String? voiceName;

  CustomSpeakingConversationSummary get summary =>
      CustomSpeakingConversationSummary(
        conversationId: conversationId,
        title: title,
        topic: topic,
        gradingEnabled: gradingEnabled,
        status: status,
        userTurnCount: userTurnCount,
        maxUserTurns: maxUserTurns,
        voiceName: voiceName,
      );

  factory CustomSpeakingChatBootstrap.fromStartStep({
    required CustomSpeakingStep step,
    required String topic,
  }) {
    return CustomSpeakingChatBootstrap(
      conversationId: step.conversationId,
      title: step.title,
      topic: topic,
      latestAiMessage: step.aiMessage,
      gradingEnabled: step.gradingEnabled,
      status: step.status,
      userTurnCount: step.userTurnCount,
      maxUserTurns: step.maxUserTurns,
      voiceName: step.voiceName,
    );
  }

  factory CustomSpeakingChatBootstrap.fromSnapshot(
    CustomConversationSnapshot snapshot,
  ) {
    return CustomSpeakingChatBootstrap(
      conversationId: snapshot.conversationId,
      title: snapshot.title,
      topic: snapshot.topic,
      latestAiMessage: snapshot.latestAiMessage,
      gradingEnabled: snapshot.gradingEnabled,
      status: snapshot.status,
      userTurnCount: snapshot.userTurnCount,
      maxUserTurns: snapshot.maxUserTurns,
      voiceName: snapshot.voiceName,
    );
  }
}

class CustomConversationSnapshot {
  const CustomConversationSnapshot({
    required this.conversationId,
    required this.title,
    required this.topic,
    required this.gradingEnabled,
    required this.status,
    required this.userTurnCount,
    required this.maxUserTurns,
    required this.updatedAt,
    this.latestAiMessage,
    this.voiceName,
  });

  final String conversationId;
  final String title;
  final String topic;
  final String? latestAiMessage;
  final bool gradingEnabled;
  final String status;
  final int userTurnCount;
  final int maxUserTurns;
  final String? voiceName;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'conversationId': conversationId,
    'title': title,
    'topic': topic,
    'latestAiMessage': latestAiMessage,
    'gradingEnabled': gradingEnabled,
    'status': status,
    'userTurnCount': userTurnCount,
    'maxUserTurns': maxUserTurns,
    'voiceName': voiceName,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  CustomSpeakingChatBootstrap toBootstrap() {
    return CustomSpeakingChatBootstrap.fromSnapshot(this);
  }

  factory CustomConversationSnapshot.fromJson(Map<String, dynamic> json) {
    return CustomConversationSnapshot(
      conversationId: json['conversationId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Custom conversation',
      topic: json['topic']?.toString() ?? '',
      latestAiMessage: json['latestAiMessage']?.toString(),
      gradingEnabled: readBool(json['gradingEnabled'], fallback: true),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      userTurnCount: readInt(json['userTurnCount']),
      maxUserTurns: readInt(json['maxUserTurns']),
      voiceName: json['voiceName']?.toString(),
      updatedAt: readDateTime(json['updatedAt']) ?? DateTime.now().toUtc(),
    );
  }
}

class CustomSpeakingRealtimeEvent {
  const CustomSpeakingRealtimeEvent({
    required this.type,
    required this.rawType,
    this.conversationId,
    this.title,
    this.turnNumber,
    this.aiMessage,
    this.audioBase64,
    this.status,
    this.userTurnCount,
    this.maxUserTurns,
    this.voiceName,
    this.errorMessage,
    this.timestamp,
  });

  final CustomSpeakingRealtimeEventType type;
  final String rawType;
  final String? conversationId;
  final String? title;
  final int? turnNumber;
  final String? aiMessage;
  final String? audioBase64;
  final String? status;
  final int? userTurnCount;
  final int? maxUserTurns;
  final String? voiceName;
  final String? errorMessage;
  final DateTime? timestamp;

  bool get isTerminal =>
      type == CustomSpeakingRealtimeEventType.conversationComplete ||
      type == CustomSpeakingRealtimeEventType.error;

  factory CustomSpeakingRealtimeEvent.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().trim().toUpperCase() ?? 'UNKNOWN';
    final type = switch (rawType) {
      'AI_MESSAGE' => CustomSpeakingRealtimeEventType.aiMessage,
      'CONVERSATION_COMPLETE' =>
        CustomSpeakingRealtimeEventType.conversationComplete,
      'ERROR' => CustomSpeakingRealtimeEventType.error,
      _ => CustomSpeakingRealtimeEventType.unknown,
    };
    return CustomSpeakingRealtimeEvent(
      type: type,
      rawType: rawType,
      conversationId: json['conversationId']?.toString(),
      title: json['title']?.toString(),
      turnNumber: readNullableInt(json['turnNumber']),
      aiMessage: json['aiMessage']?.toString(),
      audioBase64: json['audioBase64']?.toString(),
      status: json['status']?.toString(),
      userTurnCount: readNullableInt(json['userTurnCount']),
      maxUserTurns: readNullableInt(json['maxUserTurns']),
      voiceName: json['voiceName']?.toString(),
      errorMessage: json['errorMessage']?.toString(),
      timestamp: readDateTime(json['timestamp']),
    );
  }
}

class CustomSpeakingStep {
  const CustomSpeakingStep({
    required this.conversationId,
    required this.title,
    required this.turnNumber,
    this.aiMessage,
    required this.conversationComplete,
    required this.gradingEnabled,
    required this.status,
    required this.userTurnCount,
    required this.maxUserTurns,
    this.voiceName,
  });

  final String conversationId;
  final String title;
  final int turnNumber;
  final String? aiMessage;
  final bool conversationComplete;
  final bool gradingEnabled;
  final String status;
  final int userTurnCount;
  final int maxUserTurns;
  final String? voiceName;

  factory CustomSpeakingStep.fromJson(Map<String, dynamic> json) {
    return CustomSpeakingStep(
      conversationId: json['conversationId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Custom conversation',
      turnNumber: readInt(json['turnNumber']),
      aiMessage: json['aiMessage']?.toString(),
      conversationComplete: readBool(json['conversationComplete']),
      gradingEnabled: readBool(json['gradingEnabled'], fallback: true),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      userTurnCount: readInt(json['userTurnCount']),
      maxUserTurns: readInt(json['maxUserTurns']),
      voiceName: json['voiceName']?.toString(),
    );
  }
}

class CustomSpeakingTurn {
  const CustomSpeakingTurn({
    required this.id,
    required this.turnNumber,
    required this.aiMessage,
    this.userTranscript,
    this.audioUrl,
    this.timeSpentSeconds,
    this.speechAnalytics,
    this.createdAt,
  });

  final String id;
  final int turnNumber;
  final String aiMessage;
  final String? userTranscript;
  final String? audioUrl;
  final int? timeSpentSeconds;
  final SpeechAnalytics? speechAnalytics;
  final DateTime? createdAt;

  bool get isAnswered => (userTranscript ?? '').trim().isNotEmpty;

  factory CustomSpeakingTurn.fromJson(Map<String, dynamic> json) {
    return CustomSpeakingTurn(
      id: json['id']?.toString() ?? '',
      turnNumber: readInt(json['turnNumber']),
      aiMessage: json['aiMessage']?.toString() ?? '',
      userTranscript: json['userTranscript']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      timeSpentSeconds: readNullableInt(json['timeSpentSeconds']),
      speechAnalytics: json['speechAnalytics'] == null
          ? null
          : SpeechAnalytics.fromJson(readMap(json['speechAnalytics'])),
      createdAt: readDateTime(json['createdAt']),
    );
  }
}

class CustomSpeakingConversation {
  const CustomSpeakingConversation({
    required this.id,
    required this.title,
    required this.topic,
    required this.style,
    required this.personality,
    required this.expertise,
    required this.gradingEnabled,
    required this.status,
    required this.maxUserTurns,
    required this.userTurnCount,
    required this.totalTurns,
    required this.turns,
    this.voiceName,
    this.timeSpentSeconds,
    this.fluencyScore,
    this.vocabularyScore,
    this.coherenceScore,
    this.pronunciationScore,
    this.overallScore,
    this.aiFeedback,
    this.startedAt,
    this.completedAt,
    this.gradedAt,
  });

  final String id;
  final String title;
  final String topic;
  final String style;
  final String personality;
  final String expertise;
  final String? voiceName;
  final bool gradingEnabled;
  final String status;
  final int maxUserTurns;
  final int userTurnCount;
  final int totalTurns;
  final int? timeSpentSeconds;
  final double? fluencyScore;
  final double? vocabularyScore;
  final double? coherenceScore;
  final double? pronunciationScore;
  final double? overallScore;
  final String? aiFeedback;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? gradedAt;
  final List<CustomSpeakingTurn> turns;

  bool get isLocked => isCustomSpeakingLockedStatus(status);

  CustomSpeakingConversationSummary get summary =>
      CustomSpeakingConversationSummary.fromConversation(this);

  CustomSpeakingTurn? get pendingTurn {
    for (final turn in turns.reversed) {
      if (!turn.isAnswered) {
        return turn;
      }
    }
    return null;
  }

  factory CustomSpeakingConversation.fromJson(Map<String, dynamic> json) {
    final rawTurns = json['turns'];
    return CustomSpeakingConversation(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Custom conversation',
      topic: json['topic']?.toString() ?? '',
      style: json['style']?.toString() ?? customSpeakingStyleOptions.first.value,
      personality:
          json['personality']?.toString() ??
          customSpeakingPersonalityOptions.first.value,
      expertise:
          json['expertise']?.toString() ??
          customSpeakingExpertiseOptions.first.value,
      voiceName: json['voiceName']?.toString(),
      gradingEnabled: readBool(json['gradingEnabled'], fallback: true),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      maxUserTurns: readInt(json['maxUserTurns']),
      userTurnCount: readInt(json['userTurnCount']),
      totalTurns: readInt(json['totalTurns']),
      timeSpentSeconds: readNullableInt(json['timeSpentSeconds']),
      fluencyScore: readDouble(json['fluencyScore']),
      vocabularyScore: readDouble(json['vocabularyScore']),
      coherenceScore: readDouble(json['coherenceScore']),
      pronunciationScore: readDouble(json['pronunciationScore']),
      overallScore: readDouble(json['overallScore']),
      aiFeedback: json['aiFeedback']?.toString(),
      startedAt: readDateTime(json['startedAt']),
      completedAt: readDateTime(json['completedAt']),
      gradedAt: readDateTime(json['gradedAt']),
      turns: rawTurns is List
          ? rawTurns
                .whereType<Object?>()
                .map((item) => CustomSpeakingTurn.fromJson(readMap(item)))
                .toList(growable: false)
          : const <CustomSpeakingTurn>[],
    );
  }
}

class StartCustomSpeakingPayload {
  const StartCustomSpeakingPayload({
    required this.topic,
    required this.style,
    required this.personality,
    required this.expertise,
    required this.gradingEnabled,
    this.voiceName,
  });

  final String topic;
  final String style;
  final String personality;
  final String expertise;
  final String? voiceName;
  final bool gradingEnabled;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'topic': topic,
    'style': style,
    'personality': personality,
    'expertise': expertise,
    if ((voiceName ?? '').trim().isNotEmpty) 'voiceName': voiceName,
    'gradingEnabled': gradingEnabled,
  };
}

class SubmitCustomSpeakingTurnPayload {
  const SubmitCustomSpeakingTurnPayload({
    required this.transcript,
    required this.timeSpentSeconds,
    this.audioUrl,
    this.speechAnalytics,
  });

  final String transcript;
  final int timeSpentSeconds;
  final String? audioUrl;
  final SpeechAnalytics? speechAnalytics;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'transcript': transcript,
    'timeSpentSeconds': timeSpentSeconds,
    if ((audioUrl ?? '').isNotEmpty) 'audioUrl': audioUrl,
    if (speechAnalytics != null) 'speechAnalytics': speechAnalytics!.toJson(),
  };
}

class SubmitCustomSpeakingRealtimePayload {
  const SubmitCustomSpeakingRealtimePayload({
    required this.conversationId,
    required this.transcript,
    required this.timeSpentSeconds,
    this.audioUrl,
    this.speechAnalytics,
  });

  final String conversationId;
  final String transcript;
  final int timeSpentSeconds;
  final String? audioUrl;
  final SpeechAnalytics? speechAnalytics;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'action': 'submit',
    'conversationId': conversationId,
    'transcript': transcript,
    'timeSpentSeconds': timeSpentSeconds,
    if ((audioUrl ?? '').isNotEmpty) 'audioUrl': audioUrl,
    if (speechAnalytics != null) 'speechAnalytics': speechAnalytics!.toJson(),
  };
}

class FinishCustomSpeakingRealtimePayload {
  const FinishCustomSpeakingRealtimePayload({required this.conversationId});

  final String conversationId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'action': 'finish',
    'conversationId': conversationId,
  };
}
