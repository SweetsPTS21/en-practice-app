import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dictionary/dictionary_models.dart';
import '../../../core/dictionary/dictionary_providers.dart';
import '../../../core/vocabulary_check/vocabulary_check_models.dart';
import '../../../core/vocabulary_check/vocabulary_check_providers.dart';

class VocabularyCheckState {
  const VocabularyCheckState({
    this.englishWord = '',
    this.vietnameseMeaning = '',
    this.validation,
    this.result,
    this.explanation,
    this.savedWord,
    this.isValidating = false,
    this.isChecking = false,
    this.isExplaining = false,
    this.errorMessage,
  });

  final String englishWord;
  final String vietnameseMeaning;
  final VocabularyWordValidation? validation;
  final VocabularyMeaningCheckResult? result;
  final VocabularyWordExplanation? explanation;
  final DictionaryWord? savedWord;
  final bool isValidating;
  final bool isChecking;
  final bool isExplaining;
  final String? errorMessage;

  VocabularyCheckState copyWith({
    String? englishWord,
    String? vietnameseMeaning,
    Object? validation = _sentinel,
    Object? result = _sentinel,
    Object? explanation = _sentinel,
    Object? savedWord = _sentinel,
    bool? isValidating,
    bool? isChecking,
    bool? isExplaining,
    Object? errorMessage = _sentinel,
  }) {
    return VocabularyCheckState(
      englishWord: englishWord ?? this.englishWord,
      vietnameseMeaning: vietnameseMeaning ?? this.vietnameseMeaning,
      validation: identical(validation, _sentinel)
          ? this.validation
          : validation as VocabularyWordValidation?,
      result: identical(result, _sentinel) ? this.result : result as VocabularyMeaningCheckResult?,
      explanation: identical(explanation, _sentinel)
          ? this.explanation
          : explanation as VocabularyWordExplanation?,
      savedWord: identical(savedWord, _sentinel) ? this.savedWord : savedWord as DictionaryWord?,
      isValidating: isValidating ?? this.isValidating,
      isChecking: isChecking ?? this.isChecking,
      isExplaining: isExplaining ?? this.isExplaining,
      errorMessage:
          identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
    );
  }
}

class VocabularyCheckController extends AutoDisposeNotifier<VocabularyCheckState> {
  @override
  VocabularyCheckState build() => const VocabularyCheckState();

  void updateEnglishWord(String value) {
    state = state.copyWith(
      englishWord: value,
      validation: null,
      result: null,
      errorMessage: null,
    );
  }

  void updateVietnameseMeaning(String value) {
    state = state.copyWith(
      vietnameseMeaning: value,
      errorMessage: null,
    );
  }

  Future<void> validateWord() async {
    final word = state.englishWord.trim();
    if (word.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter an English word first.');
      return;
    }

    state = state.copyWith(isValidating: true, errorMessage: null, validation: null, result: null);
    try {
      final validation =
          await ref.read(vocabularyCheckServiceProvider).validateEnglishWord(word);
      state = state.copyWith(isValidating: false, validation: validation);
    } catch (error) {
      state = state.copyWith(
        isValidating: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> checkMeaning() async {
    final word = state.englishWord.trim();
    final meaning = state.vietnameseMeaning.trim();
    if (word.isEmpty || meaning.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter both the English word and your meaning.');
      return;
    }

    state = state.copyWith(isChecking: true, errorMessage: null);
    try {
      final result = await ref.read(vocabularyCheckServiceProvider).checkMeaning(
            englishWord: word,
            vietnameseMeaning: meaning,
          );
      state = state.copyWith(isChecking: false, result: result);
    } catch (error) {
      state = state.copyWith(isChecking: false, errorMessage: error.toString());
    }
  }

  Future<void> explainWord() async {
    final word = state.englishWord.trim();
    if (word.isEmpty) {
      state = state.copyWith(errorMessage: 'Enter a word before asking AI for details.');
      return;
    }

    state = state.copyWith(isExplaining: true, errorMessage: null);
    try {
      final explanation = await ref.read(vocabularyCheckServiceProvider).explainWord(word);
      state = state.copyWith(isExplaining: false, explanation: explanation);
    } catch (error) {
      state = state.copyWith(isExplaining: false, errorMessage: error.toString());
    }
  }

  Future<void> saveExplainedWord() async {
    final explanation = state.explanation;
    if (explanation == null) {
      return;
    }

    final saved =
        await ref.read(dictionaryApiProvider).addWord(explanation.toDictionaryWord().toAddPayload());
    state = state.copyWith(savedWord: saved);
  }

  void reset() {
    state = const VocabularyCheckState();
  }
}

final vocabularyCheckControllerProvider =
    AutoDisposeNotifierProvider<VocabularyCheckController, VocabularyCheckState>(
  VocabularyCheckController.new,
);

const _sentinel = Object();
