import '../productive/paged_items.dart';

class WritingTaskSummary {
  const WritingTaskSummary({
    required this.id,
    required this.taskType,
    required this.title,
    required this.difficulty,
    required this.timeLimitMinutes,
    required this.minWords,
    required this.maxWords,
    this.createdAt,
  });

  final String id;
  final String taskType;
  final String title;
  final String difficulty;
  final int timeLimitMinutes;
  final int minWords;
  final int maxWords;
  final DateTime? createdAt;

  factory WritingTaskSummary.fromJson(Map<String, dynamic> json) {
    return WritingTaskSummary(
      id: json['id']?.toString() ?? '',
      taskType: json['taskType']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? 'Writing task',
      difficulty: json['difficulty']?.toString() ?? 'MEDIUM',
      timeLimitMinutes: readInt(json['timeLimitMinutes']),
      minWords: readInt(json['minWords']),
      maxWords: readInt(json['maxWords']),
      createdAt: readDateTime(json['createdAt']),
    );
  }
}

class WritingTaskDetail {
  const WritingTaskDetail({
    required this.id,
    required this.taskType,
    required this.title,
    required this.content,
    required this.instruction,
    required this.imageUrls,
    required this.difficulty,
    required this.isPublished,
    required this.timeLimitMinutes,
    required this.minWords,
    required this.maxWords,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String taskType;
  final String title;
  final String content;
  final String instruction;
  final List<String> imageUrls;
  final String difficulty;
  final bool isPublished;
  final int timeLimitMinutes;
  final int minWords;
  final int maxWords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WritingTaskDetail.fromJson(Map<String, dynamic> json) {
    return WritingTaskDetail(
      id: json['id']?.toString() ?? '',
      taskType: json['taskType']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? 'Writing task',
      content: json['content']?.toString() ?? '',
      instruction: json['instruction']?.toString() ?? '',
      imageUrls: readStringList(json['imageUrls']),
      difficulty: json['difficulty']?.toString() ?? 'MEDIUM',
      isPublished: readBool(json['isPublished'], fallback: true),
      timeLimitMinutes: readInt(json['timeLimitMinutes']),
      minWords: readInt(json['minWords']),
      maxWords: readInt(json['maxWords']),
      createdAt: readDateTime(json['createdAt']),
      updatedAt: readDateTime(json['updatedAt']),
    );
  }
}

class WritingHighestScore {
  const WritingHighestScore({
    required this.taskId,
    required this.attempted,
    this.submissionId,
    this.highestBandScore,
    this.status,
    this.gradedAt,
  });

  final String taskId;
  final bool attempted;
  final String? submissionId;
  final double? highestBandScore;
  final String? status;
  final DateTime? gradedAt;

  bool get isPending => switch ((status ?? '').toUpperCase()) {
    'PENDING' || 'SUBMITTED' || 'GRADING' => true,
    _ => false,
  };

  factory WritingHighestScore.fromJson(Map<String, dynamic> json) {
    return WritingHighestScore(
      taskId: json['taskId']?.toString() ?? '',
      attempted: readBool(json['attempted']),
      submissionId: json['submissionId']?.toString(),
      highestBandScore: readDouble(json['highestBandScore']),
      status: json['status']?.toString(),
      gradedAt: readDateTime(json['gradedAt']),
    );
  }
}

class WritingSubmission {
  const WritingSubmission({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.taskType,
    required this.essayContent,
    required this.wordCount,
    required this.timeSpentSeconds,
    required this.status,
    this.taskResponseScore,
    this.coherenceScore,
    this.lexicalResourceScore,
    this.grammarScore,
    this.overallBandScore,
    this.aiFeedback,
    this.submittedAt,
    this.gradedAt,
  });

  final String id;
  final String taskId;
  final String taskTitle;
  final String taskType;
  final String essayContent;
  final int wordCount;
  final int? timeSpentSeconds;
  final String status;
  final double? taskResponseScore;
  final double? coherenceScore;
  final double? lexicalResourceScore;
  final double? grammarScore;
  final double? overallBandScore;
  final String? aiFeedback;
  final DateTime? submittedAt;
  final DateTime? gradedAt;

  bool get isPending => switch (status.toUpperCase()) {
    'PENDING' || 'SUBMITTED' || 'GRADING' => true,
    _ => false,
  };

  factory WritingSubmission.fromJson(Map<String, dynamic> json) {
    return WritingSubmission(
      id: json['id']?.toString() ?? '',
      taskId: json['taskId']?.toString() ?? '',
      taskTitle: json['taskTitle']?.toString() ?? 'Writing submission',
      taskType: json['taskType']?.toString() ?? 'GENERAL',
      essayContent: json['essayContent']?.toString() ?? '',
      wordCount: readInt(json['wordCount']),
      timeSpentSeconds: readNullableInt(json['timeSpentSeconds']),
      status: json['status']?.toString() ?? 'SUBMITTED',
      taskResponseScore: readDouble(json['taskResponseScore']),
      coherenceScore: readDouble(json['coherenceScore']),
      lexicalResourceScore: readDouble(json['lexicalResourceScore']),
      grammarScore: readDouble(json['grammarScore']),
      overallBandScore: readDouble(json['overallBandScore']),
      aiFeedback: json['aiFeedback']?.toString(),
      submittedAt: readDateTime(json['submittedAt']),
      gradedAt: readDateTime(json['gradedAt']),
    );
  }
}

class SubmitWritingPayload {
  const SubmitWritingPayload({
    required this.essayContent,
    required this.timeSpentSeconds,
  });

  final String essayContent;
  final int timeSpentSeconds;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'essayContent': essayContent,
    'timeSpentSeconds': timeSpentSeconds,
  };
}
