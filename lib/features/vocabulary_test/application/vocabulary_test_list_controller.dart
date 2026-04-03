import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/vocabulary_test/vocabulary_test_models.dart';
import '../../../core/vocabulary_test/vocabulary_test_providers.dart';
import '../../../core/vocabulary_test/vocabulary_test_query_params.dart';

class VocabularyTestListState {
  const VocabularyTestListState({
    required this.tests,
    required this.attempts,
    required this.questionCount,
    required this.selectedSources,
    this.isGenerating = false,
  });

  final List<VocabularyTestSummary> tests;
  final List<VocabularyTestAttemptHistoryItem> attempts;
  final int questionCount;
  final List<VocabularyTestSource> selectedSources;
  final bool isGenerating;

  VocabularyTestListState copyWith({
    List<VocabularyTestSummary>? tests,
    List<VocabularyTestAttemptHistoryItem>? attempts,
    int? questionCount,
    List<VocabularyTestSource>? selectedSources,
    bool? isGenerating,
  }) {
    return VocabularyTestListState(
      tests: tests ?? this.tests,
      attempts: attempts ?? this.attempts,
      questionCount: questionCount ?? this.questionCount,
      selectedSources: selectedSources ?? this.selectedSources,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

class VocabularyTestListController
    extends AutoDisposeAsyncNotifier<VocabularyTestListState> {
  @override
  Future<VocabularyTestListState> build() async {
    return _load();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  void updateQuestionCount(int count) {
    state = AsyncData(state.requireValue.copyWith(questionCount: count));
  }

  void toggleSource(VocabularyTestSource source) {
    final current = state.requireValue;
    final selected = [...current.selectedSources];
    if (selected.contains(source)) {
      selected.remove(source);
    } else {
      selected.add(source);
    }
    state = AsyncData(current.copyWith(selectedSources: selected));
  }

  Future<VocabularyTestDetail> generate() async {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isGenerating: true));
    try {
      final detail = await ref
          .read(vocabularyTestApiProvider)
          .generate(
            VocabularyTestGeneratePayload(
              questionCount: current.questionCount,
              sources: current.selectedSources.isEmpty
                  ? const [VocabularyTestSource.all]
                  : current.selectedSources,
              sourceSurface: 'VOCAB_TEST_DIRECT',
            ),
          );
      state = AsyncData(await _load());
      return detail;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<VocabularyTestListState> _load() async {
    final api = ref.read(vocabularyTestApiProvider);
    final tests = await api.getTests();
    final attempts = await api.getAttemptHistory(
      const VocabularyTestAttemptQueryParams(),
    );
    return VocabularyTestListState(
      tests: tests,
      attempts: attempts,
      questionCount: 10,
      selectedSources: const [VocabularyTestSource.vocabularyRecord],
    );
  }
}

final vocabularyTestListControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      VocabularyTestListController,
      VocabularyTestListState
    >(VocabularyTestListController.new);

final vocabularyTestDetailProvider = FutureProvider.autoDispose
    .family<VocabularyTestDetail, String>((ref, testId) async {
      return ref.watch(vocabularyTestApiProvider).getTestDetail(testId);
    });

final vocabularyTestAttemptDetailProvider = FutureProvider.autoDispose
    .family<VocabularyTestAttemptResult, String>((ref, attemptId) async {
      return ref.watch(vocabularyTestApiProvider).getAttemptDetail(attemptId);
    });
