import '../dictionary/dictionary_models.dart';

class VocabularyWordValidation {
  const VocabularyWordValidation({
    required this.valid,
    required this.translation,
  });

  final bool valid;
  final String translation;
}

class VocabularyMeaningCheckResult {
  const VocabularyMeaningCheckResult({
    required this.isCorrect,
    required this.translation,
    required this.alternatives,
    required this.synonyms,
  });

  final bool isCorrect;
  final String translation;
  final List<String> alternatives;
  final List<String> synonyms;
}

class VocabularyWordExplanation {
  const VocabularyWordExplanation({
    required this.word,
    required this.meaning,
    required this.examples,
    required this.synonyms,
    this.ipa,
    this.wordType,
    this.sourceType,
  });

  final String word;
  final String meaning;
  final List<String> examples;
  final List<String> synonyms;
  final String? ipa;
  final String? wordType;
  final String? sourceType;

  DictionaryWord toDictionaryWord() {
    return DictionaryWord(
      id: '',
      word: word,
      meaning: meaning,
      wordType: wordType ?? '',
      ipa: ipa ?? '',
      examples: examples,
      isFavorite: false,
      masteryLevel: 0,
      createdAt: null,
      nextReviewDate: null,
      sourceType: sourceType ?? 'OPEN_CLAW',
      synonyms: synonyms,
    );
  }
}
