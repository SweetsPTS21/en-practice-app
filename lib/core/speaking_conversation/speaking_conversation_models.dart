import '../productive/paged_items.dart';
import '../speaking/speech_analytics_models.dart';

class SpeakingConversationNextStep {
  const SpeakingConversationNextStep({
    required this.conversationId,
    required this.turnNumber,
    this.aiQuestion,
    required this.turnType,
    required this.lastTurn,
    required this.conversationComplete,
  });

  final String conversationId;
  final int turnNumber;
  final String? aiQuestion;
  final String turnType;
  final bool lastTurn;
  final bool conversationComplete;

  factory SpeakingConversationNextStep.fromJson(Map<String, dynamic> json) {
    return SpeakingConversationNextStep(
      conversationId: json['conversationId']?.toString() ?? '',
      turnNumber: readInt(json['turnNumber']),
      aiQuestion: json['aiQuestion']?.toString(),
      turnType: json['turnType']?.toString() ?? 'QUESTION',
      lastTurn: readBool(json['lastTurn']),
      conversationComplete: readBool(json['conversationComplete']),
    );
  }
}

class SpeakingConversationTurn {
  const SpeakingConversationTurn({
    required this.id,
    required this.turnNumber,
    required this.aiQuestion,
    required this.turnType,
    this.userTranscript,
    this.audioUrl,
    this.timeSpentSeconds,
    this.speechAnalytics,
    this.createdAt,
  });

  final String id;
  final int turnNumber;
  final String aiQuestion;
  final String? userTranscript;
  final String? audioUrl;
  final String turnType;
  final int? timeSpentSeconds;
  final SpeechAnalytics? speechAnalytics;
  final DateTime? createdAt;

  bool get isAnswered => (userTranscript ?? '').trim().isNotEmpty;

  factory SpeakingConversationTurn.fromJson(Map<String, dynamic> json) {
    return SpeakingConversationTurn(
      id: json['id']?.toString() ?? '',
      turnNumber: readInt(json['turnNumber']),
      aiQuestion: json['aiQuestion']?.toString() ?? '',
      userTranscript: json['userTranscript']?.toString(),
      audioUrl: json['audioUrl']?.toString(),
      turnType: json['turnType']?.toString() ?? 'QUESTION',
      timeSpentSeconds: readNullableInt(json['timeSpentSeconds']),
      speechAnalytics: json['speechAnalytics'] == null
          ? null
          : SpeechAnalytics.fromJson(readMap(json['speechAnalytics'])),
      createdAt: readDateTime(json['createdAt']),
    );
  }
}

class SpeakingConversation {
  const SpeakingConversation({
    required this.id,
    required this.topicId,
    required this.topicQuestion,
    required this.topicPart,
    required this.status,
    required this.totalTurns,
    required this.turns,
    this.timeSpentSeconds,
    this.fluencyScore,
    this.lexicalScore,
    this.grammarScore,
    this.pronunciationScore,
    this.overallBandScore,
    this.aiFeedback,
    this.startedAt,
    this.completedAt,
    this.gradedAt,
  });

  final String id;
  final String topicId;
  final String topicQuestion;
  final String topicPart;
  final String status;
  final int totalTurns;
  final int? timeSpentSeconds;
  final double? fluencyScore;
  final double? lexicalScore;
  final double? grammarScore;
  final double? pronunciationScore;
  final double? overallBandScore;
  final String? aiFeedback;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? gradedAt;
  final List<SpeakingConversationTurn> turns;

  SpeakingConversationTurn? get pendingTurn {
    for (final turn in turns.reversed) {
      if (!turn.isAnswered) {
        return turn;
      }
    }
    return null;
  }

  factory SpeakingConversation.fromJson(Map<String, dynamic> json) {
    final rawTurns = json['turns'];
    return SpeakingConversation(
      id: json['id']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      topicQuestion: json['topicQuestion']?.toString() ?? 'Conversation',
      topicPart: json['topicPart']?.toString() ?? 'PART_1',
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      totalTurns: readInt(json['totalTurns']),
      timeSpentSeconds: readNullableInt(json['timeSpentSeconds']),
      fluencyScore: readDouble(json['fluencyScore']),
      lexicalScore: readDouble(json['lexicalScore']),
      grammarScore: readDouble(json['grammarScore']),
      pronunciationScore: readDouble(json['pronunciationScore']),
      overallBandScore: readDouble(json['overallBandScore']),
      aiFeedback: json['aiFeedback']?.toString(),
      startedAt: readDateTime(json['startedAt']),
      completedAt: readDateTime(json['completedAt']),
      gradedAt: readDateTime(json['gradedAt']),
      turns: rawTurns is List
          ? rawTurns
                .whereType<Object?>()
                .map((item) => SpeakingConversationTurn.fromJson(readMap(item)))
                .toList(growable: false)
          : const <SpeakingConversationTurn>[],
    );
  }
}

class SubmitSpeakingConversationTurnPayload {
  const SubmitSpeakingConversationTurnPayload({
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
