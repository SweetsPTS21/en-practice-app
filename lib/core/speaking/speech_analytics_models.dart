import '../productive/paged_items.dart';

class SpeechWordDetail {
  const SpeechWordDetail({
    required this.word,
    this.startMs,
    this.endMs,
    this.confidence,
  });

  final String word;
  final int? startMs;
  final int? endMs;
  final double? confidence;

  factory SpeechWordDetail.fromJson(Map<String, dynamic> json) {
    return SpeechWordDetail(
      word: json['word']?.toString() ?? '',
      startMs: readNullableInt(json['startMs']),
      endMs: readNullableInt(json['endMs']),
      confidence: readDouble(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'word': word,
    if (startMs != null) 'startMs': startMs,
    if (endMs != null) 'endMs': endMs,
    if (confidence != null) 'confidence': confidence,
  };
}

class SpeechAnalytics {
  const SpeechAnalytics({
    this.wordCount,
    this.wordsPerMinute,
    this.pauseCount,
    this.avgPauseDurationMs,
    this.longPauseCount,
    this.fillerWordCount,
    this.fillerWords = const <String>[],
    this.avgWordConfidence,
    this.lowConfidenceWords = const <String>[],
    this.wordDetails = const <SpeechWordDetail>[],
  });

  final int? wordCount;
  final double? wordsPerMinute;
  final int? pauseCount;
  final double? avgPauseDurationMs;
  final int? longPauseCount;
  final int? fillerWordCount;
  final List<String> fillerWords;
  final double? avgWordConfidence;
  final List<String> lowConfidenceWords;
  final List<SpeechWordDetail> wordDetails;

  bool get hasAnySignal =>
      wordCount != null ||
      wordsPerMinute != null ||
      pauseCount != null ||
      fillerWordCount != null ||
      avgWordConfidence != null;

  factory SpeechAnalytics.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['wordDetails'];
    return SpeechAnalytics(
      wordCount: readNullableInt(json['wordCount']),
      wordsPerMinute: readDouble(json['wordsPerMinute']),
      pauseCount: readNullableInt(json['pauseCount']),
      avgPauseDurationMs: readDouble(json['avgPauseDurationMs']),
      longPauseCount: readNullableInt(json['longPauseCount']),
      fillerWordCount: readNullableInt(json['fillerWordCount']),
      fillerWords: readStringList(json['fillerWords']),
      avgWordConfidence: readDouble(json['avgWordConfidence']),
      lowConfidenceWords: readStringList(json['lowConfidenceWords']),
      wordDetails: rawDetails is List
          ? rawDetails
                .whereType<Object?>()
                .map((item) => SpeechWordDetail.fromJson(readMap(item)))
                .toList(growable: false)
          : const <SpeechWordDetail>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (wordCount != null) 'wordCount': wordCount,
    if (wordsPerMinute != null) 'wordsPerMinute': wordsPerMinute,
    if (pauseCount != null) 'pauseCount': pauseCount,
    if (avgPauseDurationMs != null) 'avgPauseDurationMs': avgPauseDurationMs,
    if (longPauseCount != null) 'longPauseCount': longPauseCount,
    if (fillerWordCount != null) 'fillerWordCount': fillerWordCount,
    if (fillerWords.isNotEmpty) 'fillerWords': fillerWords,
    if (avgWordConfidence != null) 'avgWordConfidence': avgWordConfidence,
    if (lowConfidenceWords.isNotEmpty) 'lowConfidenceWords': lowConfidenceWords,
    if (wordDetails.isNotEmpty)
      'wordDetails': wordDetails
          .map((item) => item.toJson())
          .toList(growable: false),
  };
}
