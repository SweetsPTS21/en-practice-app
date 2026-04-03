enum ReviewFilter {
  all,
  today,
  week,
  month,
  wrong,
}

class ReviewWord {
  const ReviewWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.alternatives,
    required this.examples,
    required this.wordType,
    required this.ipa,
    required this.explanation,
  });

  final String id;
  final String word;
  final String meaning;
  final List<String> alternatives;
  final List<String> examples;
  final String wordType;
  final String ipa;
  final String explanation;

  factory ReviewWord.fromJson(Map<String, dynamic> json) {
    return ReviewWord(
      id: json['id']?.toString() ??
          json['wordId']?.toString() ??
          json['reviewableId']?.toString() ??
          json['englishWord']?.toString() ??
          '',
      word: json['word']?.toString() ?? json['englishWord']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? json['correctMeaning']?.toString() ?? '',
      alternatives: _strings(json['alternatives']),
      examples: _strings(json['examples']),
      wordType: (json['wordType'] ?? json['partOfSpeech'] ?? '').toString().toUpperCase(),
      ipa: json['ipa']?.toString() ?? json['phonetic']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class ReviewCounts {
  const ReviewCounts({
    required this.today,
    required this.week,
    required this.month,
    required this.wrong,
    required this.all,
  });

  final int today;
  final int week;
  final int month;
  final int wrong;
  final int all;

  factory ReviewCounts.fromJson(Map<String, dynamic> json) {
    return ReviewCounts(
      today: _asInt(json['today']),
      week: _asInt(json['week']),
      month: _asInt(json['month']),
      wrong: _asInt(json['wrong']),
      all: _asInt(json['all']),
    );
  }
}

class ReviewWordResult {
  const ReviewWordResult({
    required this.englishWord,
    required this.isCorrect,
  });

  final String englishWord;
  final bool isCorrect;

  Map<String, dynamic> toJson() => {
        'englishWord': englishWord,
        'isCorrect': isCorrect,
      };
}

class ReviewSessionPayload {
  const ReviewSessionPayload({
    required this.filter,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.accuracy,
    required this.words,
  });

  final ReviewFilter filter;
  final int total;
  final int correct;
  final int incorrect;
  final double accuracy;
  final List<ReviewWordResult> words;

  Map<String, dynamic> toJson() => {
        'filter': filter.name,
        'total': total,
        'correct': correct,
        'incorrect': incorrect,
        'accuracy': accuracy,
        'words': words.map((item) => item.toJson()).toList(growable: false),
      };
}

class ReviewSessionSummary {
  const ReviewSessionSummary({
    required this.sessionId,
    required this.filter,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.accuracy,
    this.createdAt,
  });

  final String sessionId;
  final String filter;
  final int total;
  final int correct;
  final int incorrect;
  final double accuracy;
  final DateTime? createdAt;

  factory ReviewSessionSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSessionSummary(
      sessionId: json['id']?.toString() ?? json['sessionId']?.toString() ?? '',
      filter: json['filter']?.toString() ?? '',
      total: _asInt(json['total']),
      correct: _asInt(json['correct']),
      incorrect: _asInt(json['incorrect']),
      accuracy: (json['accuracy'] is num)
          ? (json['accuracy'] as num).toDouble()
          : double.tryParse(json['accuracy']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

List<String> _strings(Object? value) {
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
