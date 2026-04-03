import '../productive/paged_items.dart';
import '../speaking/speech_analytics_models.dart';

const customSpeakingStyleOptions = <String>[
  'CASUAL',
  'PROFESSIONAL',
  'ENCOURAGING',
  'CHALLENGING',
  'PLAYFUL',
  'DEEP',
  'DEBATE',
];

const customSpeakingPersonalityOptions = <String>[
  'FRIENDLY',
  'HUMOROUS',
  'PATIENT',
  'STRAIGHTFORWARD',
  'CONFIDENT',
  'CURIOUS',
  'EMPATHETIC',
];

const customSpeakingExpertiseOptions = <String>[
  'GENERAL',
  'BUSINESS',
  'TECHNOLOGY',
  'EDUCATION',
  'TRAVEL',
  'RELATIONSHIPS',
  'ENTERTAINMENT',
];

const customSpeakingVoiceOptions = <String>[
  'US_NEURAL_J',
  'US_NEURAL_I',
  'US_NEURAL_F',
  'US_NEURAL_C',
  'US_NEURAL_H',
  'US_STUDIO_O',
  'US_CHIRP_F',
];

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
      gradingEnabled: readBool(json['gradingEnabled']),
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
      style: json['style']?.toString() ?? 'CASUAL',
      personality: json['personality']?.toString() ?? 'FRIENDLY',
      expertise: json['expertise']?.toString() ?? 'GENERAL',
      voiceName: json['voiceName']?.toString(),
      gradingEnabled: readBool(json['gradingEnabled']),
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
    required this.voiceName,
    required this.gradingEnabled,
  });

  final String topic;
  final String style;
  final String personality;
  final String expertise;
  final String voiceName;
  final bool gradingEnabled;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'topic': topic,
    'style': style,
    'personality': personality,
    'expertise': expertise,
    'voiceName': voiceName,
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
