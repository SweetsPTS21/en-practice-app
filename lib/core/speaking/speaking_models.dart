import '../productive/paged_items.dart';
import 'speech_analytics_models.dart';

class SpeakingTopicSummary {
  const SpeakingTopicSummary({
    required this.id,
    required this.part,
    required this.question,
    required this.difficulty,
    this.createdAt,
  });

  final String id;
  final String part;
  final String question;
  final String difficulty;
  final DateTime? createdAt;

  factory SpeakingTopicSummary.fromJson(Map<String, dynamic> json) {
    return SpeakingTopicSummary(
      id: json['id']?.toString() ?? '',
      part: json['part']?.toString() ?? 'PART_1',
      question: json['question']?.toString() ?? 'Speaking topic',
      difficulty: json['difficulty']?.toString() ?? 'MEDIUM',
      createdAt: readDateTime(json['createdAt']),
    );
  }
}

class SpeakingTopicDetail {
  const SpeakingTopicDetail({
    required this.id,
    required this.part,
    required this.question,
    required this.cueCard,
    required this.followUpQuestions,
    required this.difficulty,
    required this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String part;
  final String question;
  final String cueCard;
  final List<String> followUpQuestions;
  final String difficulty;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SpeakingTopicDetail.fromJson(Map<String, dynamic> json) {
    return SpeakingTopicDetail(
      id: json['id']?.toString() ?? '',
      part: json['part']?.toString() ?? 'PART_1',
      question: json['question']?.toString() ?? 'Speaking topic',
      cueCard: json['cueCard']?.toString() ?? '',
      followUpQuestions: readStringList(json['followUpQuestions']),
      difficulty: json['difficulty']?.toString() ?? 'MEDIUM',
      isPublished: readBool(json['isPublished'], fallback: true),
      createdAt: readDateTime(json['createdAt']),
      updatedAt: readDateTime(json['updatedAt']),
    );
  }
}

class SpeakingHighestScore {
  const SpeakingHighestScore({
    required this.topicId,
    required this.attempted,
    this.attemptId,
    this.conversationId,
    this.highestBandScore,
    this.status,
    this.sourceType,
    this.gradedAt,
  });

  final String topicId;
  final bool attempted;
  final String? attemptId;
  final String? conversationId;
  final double? highestBandScore;
  final String? status;
  final String? sourceType;
  final DateTime? gradedAt;

  factory SpeakingHighestScore.fromJson(Map<String, dynamic> json) {
    return SpeakingHighestScore(
      topicId: json['topicId']?.toString() ?? '',
      attempted: readBool(json['attempted']),
      attemptId: json['attemptId']?.toString(),
      conversationId: json['conversationId']?.toString(),
      highestBandScore: readDouble(json['highestBandScore']),
      status: json['status']?.toString(),
      sourceType: json['sourceType']?.toString(),
      gradedAt: readDateTime(json['gradedAt']),
    );
  }
}

class SpeakingAttempt {
  const SpeakingAttempt({
    required this.id,
    required this.topicId,
    required this.topicQuestion,
    required this.topicPart,
    required this.transcript,
    required this.status,
    this.audioUrl,
    this.timeSpentSeconds,
    this.fluencyScore,
    this.lexicalScore,
    this.grammarScore,
    this.pronunciationScore,
    this.overallBandScore,
    this.aiFeedback,
    this.speechAnalytics,
    this.submittedAt,
    this.gradedAt,
  });

  final String id;
  final String topicId;
  final String topicQuestion;
  final String topicPart;
  final String? audioUrl;
  final String transcript;
  final int? timeSpentSeconds;
  final String status;
  final double? fluencyScore;
  final double? lexicalScore;
  final double? grammarScore;
  final double? pronunciationScore;
  final double? overallBandScore;
  final String? aiFeedback;
  final SpeechAnalytics? speechAnalytics;
  final DateTime? submittedAt;
  final DateTime? gradedAt;

  bool get isPending => switch (status.toUpperCase()) {
    'PENDING' || 'SUBMITTED' || 'GRADING' => true,
    _ => false,
  };

  factory SpeakingAttempt.fromJson(Map<String, dynamic> json) {
    return SpeakingAttempt(
      id: json['id']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      topicQuestion: json['topicQuestion']?.toString() ?? 'Speaking practice',
      topicPart: json['topicPart']?.toString() ?? 'PART_1',
      audioUrl: json['audioUrl']?.toString(),
      transcript: json['transcript']?.toString() ?? '',
      timeSpentSeconds: readNullableInt(json['timeSpentSeconds']),
      status: json['status']?.toString() ?? 'SUBMITTED',
      fluencyScore: readDouble(json['fluencyScore']),
      lexicalScore: readDouble(json['lexicalScore']),
      grammarScore: readDouble(json['grammarScore']),
      pronunciationScore: readDouble(json['pronunciationScore']),
      overallBandScore: readDouble(json['overallBandScore']),
      aiFeedback: json['aiFeedback']?.toString(),
      speechAnalytics: json['speechAnalytics'] == null
          ? null
          : SpeechAnalytics.fromJson(readMap(json['speechAnalytics'])),
      submittedAt: readDateTime(json['submittedAt']),
      gradedAt: readDateTime(json['gradedAt']),
    );
  }
}

class SubmitSpeakingPayload {
  const SubmitSpeakingPayload({
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
