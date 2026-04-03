import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dictionary/dictionary_providers.dart';
import '../../../core/dictionary/review_models.dart';

class DictionaryReviewState {
  const DictionaryReviewState({
    required this.filter,
    required this.limit,
    required this.counts,
    required this.words,
    required this.answers,
    required this.currentIndex,
    required this.isSubmitting,
    required this.isCompleted,
    this.session,
  });

  final ReviewFilter filter;
  final int limit;
  final ReviewCounts counts;
  final List<ReviewWord> words;
  final Map<String, bool> answers;
  final int currentIndex;
  final bool isSubmitting;
  final bool isCompleted;
  final ReviewSessionSummary? session;

  ReviewWord? get currentWord =>
      currentIndex >= 0 && currentIndex < words.length ? words[currentIndex] : null;

  double get progress => words.isEmpty ? 0 : currentIndex / words.length;

  int get correctCount => answers.values.where((value) => value).length;

  int get incorrectCount => answers.length - correctCount;

  DictionaryReviewState copyWith({
    ReviewFilter? filter,
    int? limit,
    ReviewCounts? counts,
    List<ReviewWord>? words,
    Map<String, bool>? answers,
    int? currentIndex,
    bool? isSubmitting,
    bool? isCompleted,
    Object? session = _sentinel,
  }) {
    return DictionaryReviewState(
      filter: filter ?? this.filter,
      limit: limit ?? this.limit,
      counts: counts ?? this.counts,
      words: words ?? this.words,
      answers: answers ?? this.answers,
      currentIndex: currentIndex ?? this.currentIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      session: identical(session, _sentinel) ? this.session : session as ReviewSessionSummary?,
    );
  }
}

class DictionaryReviewArgs {
  const DictionaryReviewArgs({
    required this.filter,
    required this.limit,
  });

  final ReviewFilter filter;
  final int limit;
}

class DictionaryReviewController
    extends AutoDisposeFamilyAsyncNotifier<DictionaryReviewState, DictionaryReviewArgs> {
  @override
  Future<DictionaryReviewState> build(DictionaryReviewArgs arg) async {
    final api = ref.watch(reviewApiProvider);
    final counts = await api.getReviewCounts();
    final words = await api.getReviewWords(
      filter: arg.filter,
      limit: arg.limit,
    );
    return DictionaryReviewState(
      filter: arg.filter,
      limit: arg.limit,
      counts: counts,
      words: words,
      answers: const <String, bool>{},
      currentIndex: 0,
      isSubmitting: false,
      isCompleted: false,
    );
  }

  Future<ReviewSessionSummary?> answerCurrent(bool isCorrect) async {
    final current = state.requireValue;
    final word = current.currentWord;
    if (word == null) {
      return current.session;
    }

    final answers = Map<String, bool>.from(current.answers)..[word.word] = isCorrect;
    final nextIndex = current.currentIndex + 1;
    final isDone = nextIndex >= current.words.length;
    state = AsyncData(
      current.copyWith(
        answers: answers,
        currentIndex: isDone ? current.currentIndex : nextIndex,
        isCompleted: isDone,
      ),
    );

    if (!isDone) {
      return null;
    }

    return _submitCurrentSession();
  }

  Future<ReviewSessionSummary?> _submitCurrentSession() async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isSubmitting: true));
    try {
      final total = current.words.length;
      final correct = current.correctCount;
      final session = await ref.read(reviewApiProvider).submitReviewSession(
            ReviewSessionPayload(
              filter: current.filter,
              total: total,
              correct: correct,
              incorrect: total - correct,
              accuracy: total == 0 ? 0 : (correct / total) * 100,
              words: current.words
                  .map(
                    (word) => ReviewWordResult(
                      englishWord: word.word,
                      isCorrect: current.answers[word.word] ?? false,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
      state = AsyncData(state.requireValue.copyWith(isSubmitting: false, session: session));
      return session;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

final dictionaryReviewControllerProvider = AutoDisposeAsyncNotifierProviderFamily<
    DictionaryReviewController, DictionaryReviewState, DictionaryReviewArgs>(
  DictionaryReviewController.new,
);

const _sentinel = Object();
