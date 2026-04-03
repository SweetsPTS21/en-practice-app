import '../network/json_helpers.dart';
import 'weekly_challenge_models.dart';

class FlagshipRetention {
  const FlagshipRetention({
    this.dailySpeakingPrompt,
    this.vocabMicroLearning,
    this.weeklyChallenge,
  });

  final DailySpeakingPrompt? dailySpeakingPrompt;
  final VocabMicroLearning? vocabMicroLearning;
  final WeeklyChallenge? weeklyChallenge;

  bool get hasAnyBlock =>
      dailySpeakingPrompt != null || vocabMicroLearning != null || weeklyChallenge != null;

  factory FlagshipRetention.fromJson(Map<String, dynamic> json) {
    return FlagshipRetention(
      dailySpeakingPrompt: json['dailySpeakingPrompt'] is Map
          ? DailySpeakingPrompt.fromJson(jsonMap(json['dailySpeakingPrompt']))
          : null,
      vocabMicroLearning: json['vocabMicroLearning'] is Map
          ? VocabMicroLearning.fromJson(jsonMap(json['vocabMicroLearning']))
          : null,
      weeklyChallenge: json['weeklyChallenge'] is Map
          ? WeeklyChallenge.fromJson(jsonMap(json['weeklyChallenge']))
          : null,
    );
  }
}

class DailySpeakingPrompt {
  const DailySpeakingPrompt({
    required this.promptId,
    required this.topic,
    required this.prompt,
    required this.persona,
    required this.difficulty,
    required this.actionUrl,
    required this.reason,
    this.estimatedMinutes,
    this.resumeState,
  });

  final String promptId;
  final String topic;
  final String prompt;
  final String persona;
  final String difficulty;
  final String actionUrl;
  final String reason;
  final int? estimatedMinutes;
  final String? resumeState;

  factory DailySpeakingPrompt.fromJson(Map<String, dynamic> json) {
    return DailySpeakingPrompt(
      promptId: json['promptId']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      persona: json['persona']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '/speaking?mode=quick',
      reason: json['reason']?.toString() ?? 'DAILY_SPEAKING_PROMPT',
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      resumeState: json['resumeState']?.toString(),
    );
  }
}

class VocabMicroLearning {
  const VocabMicroLearning({
    required this.title,
    required this.description,
    required this.actionUrl,
    required this.reason,
    required this.words,
    this.estimatedMinutes,
    this.targetWordCount,
    this.dueWordCount,
  });

  final String title;
  final String description;
  final String actionUrl;
  final String reason;
  final List<VocabMicroLearningWord> words;
  final int? estimatedMinutes;
  final int? targetWordCount;
  final int? dueWordCount;

  factory VocabMicroLearning.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'];
    return VocabMicroLearning(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '/dictionary/review?mode=micro',
      reason: json['reason']?.toString() ?? 'VOCAB_MICRO_SESSION',
      estimatedMinutes: _readInt(json['estimatedMinutes']),
      targetWordCount: _readInt(json['targetWordCount']),
      dueWordCount: _readInt(json['dueWordCount']),
      words: rawWords is List
          ? rawWords
              .whereType<Object?>()
              .map((item) => VocabMicroLearningWord.fromJson(jsonMap(item)))
              .toList(growable: false)
          : const <VocabMicroLearningWord>[],
    );
  }
}

class VocabMicroLearningWord {
  const VocabMicroLearningWord({
    required this.id,
    required this.word,
    this.meaning,
    this.source,
  });

  final String id;
  final String word;
  final String? meaning;
  final String? source;

  factory VocabMicroLearningWord.fromJson(Map<String, dynamic> json) {
    return VocabMicroLearningWord(
      id: json['id']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString(),
      source: json['source']?.toString(),
    );
  }
}

int? _readInt(Object? value) {
  return switch (value) {
    int value => value,
    num value => value.toInt(),
    String value => int.tryParse(value),
    _ => null,
  };
}
