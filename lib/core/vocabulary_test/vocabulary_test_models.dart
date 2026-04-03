import '../network/json_helpers.dart';

enum VocabularyTestSource {
  vocabularyRecord('VOCABULARY_RECORD', 'Review history'),
  userDictionary('USER_DICTIONARY', 'My dictionary'),
  userWordLookupEvent('USER_WORD_LOOKUP_EVENT', 'Recent lookups'),
  all('ALL', 'All sources');

  const VocabularyTestSource(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

enum VocabularyTestStatus {
  ready,
  failed,
  inProgress,
  completed,
  unknown,
}

class VocabularyTestQuestion {
  const VocabularyTestQuestion({
    required this.questionId,
    required this.order,
    required this.sourceWord,
    required this.sourceType,
    required this.questionText,
    required this.blankSentence,
    required this.options,
  });

  final String questionId;
  final int order;
  final String sourceWord;
  final String sourceType;
  final String questionText;
  final String blankSentence;
  final List<String> options;

  factory VocabularyTestQuestion.fromJson(Map<String, dynamic> json) {
    return VocabularyTestQuestion(
      questionId: json['questionId']?.toString() ?? '',
      order: _asInt(json['order']),
      sourceWord: json['sourceWord']?.toString() ?? '',
      sourceType: json['sourceType']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      blankSentence: json['blankSentence']?.toString() ?? '',
      options: _stringList(json['options']),
    );
  }
}

class VocabularyTestSummary {
  const VocabularyTestSummary({
    required this.testId,
    required this.title,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.selectedSources,
    required this.createdAt,
    required this.attemptCount,
    required this.latestStatus,
    this.latestAccuracyPercent,
  });

  final String testId;
  final String title;
  final int questionCount;
  final int estimatedMinutes;
  final List<String> selectedSources;
  final DateTime? createdAt;
  final int attemptCount;
  final VocabularyTestStatus latestStatus;
  final double? latestAccuracyPercent;

  factory VocabularyTestSummary.fromJson(Map<String, dynamic> json) {
    return VocabularyTestSummary(
      testId: json['testId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Vocabulary test',
      questionCount: _asInt(json['questionCount']),
      estimatedMinutes: _asInt(json['estimatedMinutes']),
      selectedSources: _stringList(json['selectedSources']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      attemptCount: _asInt(json['attemptCount']),
      latestStatus: _statusFromString(json['latestAttemptStatus']?.toString()),
      latestAccuracyPercent: _asDoubleOrNull(json['latestAccuracyPercent']),
    );
  }
}

class VocabularyTestDetail {
  const VocabularyTestDetail({
    required this.testId,
    required this.title,
    required this.status,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.selectedSources,
    required this.createdAt,
    required this.questions,
  });

  final String testId;
  final String title;
  final VocabularyTestStatus status;
  final int questionCount;
  final int estimatedMinutes;
  final List<String> selectedSources;
  final DateTime? createdAt;
  final List<VocabularyTestQuestion> questions;

  factory VocabularyTestDetail.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'];
    return VocabularyTestDetail(
      testId: json['testId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Vocabulary test',
      status: _statusFromString(json['status']?.toString()),
      questionCount: _asInt(json['questionCount']),
      estimatedMinutes: _asInt(json['estimatedMinutes']),
      selectedSources: _stringList(json['selectedSources']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      questions: questions is List
          ? questions
              .whereType<Object?>()
              .map((item) => VocabularyTestQuestion.fromJson(jsonMap(item)))
              .toList(growable: false)
          : const <VocabularyTestQuestion>[],
    );
  }
}

class StartVocabularyTestResponse {
  const StartVocabularyTestResponse({
    required this.attemptId,
    required this.testId,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.testDetail,
  });

  final String attemptId;
  final String testId;
  final int questionCount;
  final int estimatedMinutes;
  final VocabularyTestDetail testDetail;

  factory StartVocabularyTestResponse.fromJson(Map<String, dynamic> json) {
    return StartVocabularyTestResponse(
      attemptId: json['attemptId']?.toString() ?? '',
      testId: json['testId']?.toString() ?? '',
      questionCount: _asInt(json['questionCount']),
      estimatedMinutes: _asInt(json['estimatedMinutes']),
      testDetail: VocabularyTestDetail.fromJson(jsonMap(json['testDetail'])),
    );
  }
}

class VocabularyTestAnswerResult {
  const VocabularyTestAnswerResult({
    required this.questionId,
    required this.order,
    required this.sourceWord,
    required this.questionText,
    required this.blankSentence,
    required this.options,
    required this.correctOptionIndex,
    required this.correctAnswer,
    required this.isCorrect,
    this.selectedOptionIndex,
    this.selectedAnswer,
    this.explanation,
  });

  final String questionId;
  final int order;
  final String sourceWord;
  final String questionText;
  final String blankSentence;
  final List<String> options;
  final int correctOptionIndex;
  final String correctAnswer;
  final bool isCorrect;
  final int? selectedOptionIndex;
  final String? selectedAnswer;
  final String? explanation;

  factory VocabularyTestAnswerResult.fromJson(Map<String, dynamic> json) {
    return VocabularyTestAnswerResult(
      questionId: json['questionId']?.toString() ?? '',
      order: _asInt(json['order']),
      sourceWord: json['sourceWord']?.toString() ?? '',
      questionText: json['questionText']?.toString() ?? '',
      blankSentence: json['blankSentence']?.toString() ?? '',
      options: _stringList(json['options']),
      correctOptionIndex: _asInt(json['correctOptionIndex']),
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      isCorrect: json['isCorrect'] == true,
      selectedOptionIndex: _asNullableInt(json['selectedOptionIndex']),
      selectedAnswer: json['selectedAnswer']?.toString(),
      explanation: json['explanation']?.toString(),
    );
  }
}

class VocabularyTestAttemptResult {
  const VocabularyTestAttemptResult({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.totalQuestions,
    required this.correctCount,
    required this.accuracyPercent,
    required this.status,
    required this.results,
    this.timeSpentSeconds,
    this.startedAt,
    this.completedAt,
    this.testDetail,
  });

  final String attemptId;
  final String testId;
  final String testTitle;
  final int totalQuestions;
  final int correctCount;
  final double accuracyPercent;
  final VocabularyTestStatus status;
  final List<VocabularyTestAnswerResult> results;
  final int? timeSpentSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final VocabularyTestDetail? testDetail;

  bool get isCompleted => status == VocabularyTestStatus.completed || results.isNotEmpty;

  factory VocabularyTestAttemptResult.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    return VocabularyTestAttemptResult(
      attemptId: json['attemptId']?.toString() ?? '',
      testId: json['testId']?.toString() ?? '',
      testTitle:
          json['testTitle']?.toString() ?? json['title']?.toString() ?? 'Vocabulary test',
      totalQuestions: _asInt(json['totalQuestions'] ?? json['questionCount']),
      correctCount: _asInt(json['correctCount']),
      accuracyPercent: _asDouble(json['accuracyPercent']),
      status: _statusFromString(json['status']?.toString()),
      results: results is List
          ? results
              .whereType<Object?>()
              .map((item) => VocabularyTestAnswerResult.fromJson(jsonMap(item)))
              .toList(growable: false)
          : const <VocabularyTestAnswerResult>[],
      timeSpentSeconds: _asNullableInt(json['timeSpentSeconds']),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      testDetail: json['testDetail'] == null
          ? null
          : VocabularyTestDetail.fromJson(jsonMap(json['testDetail'])),
    );
  }
}

class VocabularyTestAttemptHistoryItem {
  const VocabularyTestAttemptHistoryItem({
    required this.attemptId,
    required this.testId,
    required this.testTitle,
    required this.totalQuestions,
    required this.correctCount,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.accuracyPercent,
  });

  final String attemptId;
  final String testId;
  final String testTitle;
  final int totalQuestions;
  final int correctCount;
  final VocabularyTestStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? accuracyPercent;

  factory VocabularyTestAttemptHistoryItem.fromJson(Map<String, dynamic> json) {
    return VocabularyTestAttemptHistoryItem(
      attemptId: json['attemptId']?.toString() ?? '',
      testId: json['testId']?.toString() ?? '',
      testTitle: json['testTitle']?.toString() ?? 'Vocabulary test',
      totalQuestions: _asInt(json['totalQuestions']),
      correctCount: _asInt(json['correctCount']),
      status: _statusFromString(json['status']?.toString()),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      accuracyPercent: _asDoubleOrNull(json['accuracyPercent']),
    );
  }
}

class VocabularyTestGeneratePayload {
  const VocabularyTestGeneratePayload({
    required this.questionCount,
    required this.sources,
    required this.sourceSurface,
  });

  final int questionCount;
  final List<VocabularyTestSource> sources;
  final String sourceSurface;

  Map<String, dynamic> toJson() => {
        'questionCount': questionCount,
        'sources': sources.map((item) => item.apiValue).toList(growable: false),
        'sourceSurface': sourceSurface,
      };
}

class VocabularyTestSubmitAnswer {
  const VocabularyTestSubmitAnswer({
    required this.questionId,
    required this.selectedOptionIndex,
  });

  final String questionId;
  final int selectedOptionIndex;

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'selectedOptionIndex': selectedOptionIndex,
      };
}

class VocabularyTestSubmitPayload {
  const VocabularyTestSubmitPayload({
    required this.timeSpentSeconds,
    required this.answers,
  });

  final int timeSpentSeconds;
  final List<VocabularyTestSubmitAnswer> answers;

  Map<String, dynamic> toJson() => {
        'timeSpentSeconds': timeSpentSeconds,
        'answers': answers.map((item) => item.toJson()).toList(growable: false),
      };
}

VocabularyTestStatus _statusFromString(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'READY':
      return VocabularyTestStatus.ready;
    case 'FAILED':
      return VocabularyTestStatus.failed;
    case 'IN_PROGRESS':
      return VocabularyTestStatus.inProgress;
    case 'COMPLETED':
      return VocabularyTestStatus.completed;
    default:
      return VocabularyTestStatus.unknown;
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }
  return value
      .whereType<Object?>()
      .map((item) => item?.toString() ?? '')
      .where((item) => item.trim().isNotEmpty)
      .toList(growable: false);
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value.toString());
}

double _asDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asDoubleOrNull(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}
