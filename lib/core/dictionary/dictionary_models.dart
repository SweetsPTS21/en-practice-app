import '../network/json_helpers.dart';

class DictionaryWord {
  const DictionaryWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.wordType,
    required this.ipa,
    required this.examples,
    required this.isFavorite,
    required this.masteryLevel,
    required this.createdAt,
    required this.nextReviewDate,
    this.sourceType,
    this.explanation,
    this.alternatives = const <String>[],
    this.synonyms = const <String>[],
  });

  final String id;
  final String word;
  final String meaning;
  final String wordType;
  final String ipa;
  final List<String> examples;
  final bool isFavorite;
  final int masteryLevel;
  final DateTime? createdAt;
  final DateTime? nextReviewDate;
  final String? sourceType;
  final String? explanation;
  final List<String> alternatives;
  final List<String> synonyms;

  bool get isMastered => masteryLevel >= 4;

  factory DictionaryWord.fromJson(Map<String, dynamic> json) {
    return DictionaryWord(
      id: json['id']?.toString() ?? json['wordId']?.toString() ?? '',
      word: json['word']?.toString() ?? json['englishWord']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? json['correctMeaning']?.toString() ?? '',
      wordType: (json['wordType'] ?? json['type'] ?? '').toString().toUpperCase(),
      ipa: json['ipa']?.toString() ?? json['phonetic']?.toString() ?? '',
      examples: _stringList(json['examples']),
      isFavorite: json['isFavorite'] == true,
      masteryLevel: _asInt(json['masteryLevel']),
      createdAt: _asDateTime(json['createdAt']),
      nextReviewDate: _asDateTime(json['nextReviewDate']),
      sourceType: json['sourceType']?.toString(),
      explanation: json['explanation']?.toString(),
      alternatives: _stringList(json['alternatives']),
      synonyms: _stringList(json['synonyms']),
    );
  }

  Map<String, dynamic> toAddPayload() {
    return {
      'word': word,
      if (ipa.isNotEmpty) 'ipa': ipa,
      if (wordType.isNotEmpty) 'wordType': wordType,
      'meaning': meaning,
      if (examples.isNotEmpty) 'examples': examples,
      if (sourceType != null && sourceType!.isNotEmpty) 'sourceType': sourceType,
    };
  }
}

class DictionaryWordPage {
  const DictionaryWordPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<DictionaryWord> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  factory DictionaryWordPage.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'];
    final content = rawContent is List
        ? rawContent
            .whereType<Object?>()
            .map((item) => DictionaryWord.fromJson(jsonMap(item)))
            .toList(growable: false)
        : const <DictionaryWord>[];
    final totalElements = _asInt(json['totalElements']);
    final size = _asInt(json['size'], fallback: content.length);
    return DictionaryWordPage(
      content: content,
      page: _asInt(json['page']),
      size: size,
      totalElements: totalElements,
      totalPages: _asInt(
        json['totalPages'],
        fallback: size == 0 ? 0 : (totalElements / size).ceil(),
      ),
    );
  }
}

class DictionaryStats {
  const DictionaryStats({
    required this.totalWords,
    required this.masteredWords,
    required this.dueReviews,
    required this.favoriteWords,
  });

  final int totalWords;
  final int masteredWords;
  final int dueReviews;
  final int favoriteWords;

  factory DictionaryStats.fromJson(Map<String, dynamic> json) {
    return DictionaryStats(
      totalWords: _asInt(json['totalWords']),
      masteredWords: _asInt(json['masteredWords']),
      dueReviews: _asInt(json['dueReviews'] ?? json['wordsToReviewToday']),
      favoriteWords: _asInt(json['favoriteWords']),
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value
      .where((item) => item != null && item.toString().trim().isNotEmpty)
      .map((item) => item.toString())
      .toList(growable: false);
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _asDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}
