import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ielts/ielts_models.dart';
import '../../../core/ielts/ielts_providers.dart';
import '../../../core/ielts/ielts_query_params.dart';
import '../../../core/productive/paged_items.dart';

class IeltsListState {
  const IeltsListState({
    required this.query,
    required this.tests,
    required this.attempts,
  });

  final IeltsTestQueryParams? query;
  final PagedItems<IeltsTestSummary> tests;
  final List<IeltsAttemptHistoryItem> attempts;

  IeltsTestQueryParams get resolvedQuery => query ?? const IeltsTestQueryParams();

  IeltsListState copyWith({
    IeltsTestQueryParams? query,
    PagedItems<IeltsTestSummary>? tests,
    List<IeltsAttemptHistoryItem>? attempts,
  }) {
    return IeltsListState(
      query: query ?? this.query,
      tests: tests ?? this.tests,
      attempts: attempts ?? this.attempts,
    );
  }
}

class IeltsListController extends AutoDisposeAsyncNotifier<IeltsListState> {
  @override
  Future<IeltsListState> build() async {
    return _load(const IeltsTestQueryParams());
  }

  Future<void> refresh() async {
    final currentQuery =
        state.valueOrNull?.resolvedQuery ?? const IeltsTestQueryParams();
    state = await AsyncValue.guard(
      () => _load(currentQuery),
    );
  }

  Future<void> selectSkill(IeltsSkill? skill) async {
    final current =
        state.valueOrNull?.resolvedQuery ?? const IeltsTestQueryParams();
    state = const AsyncLoading<IeltsListState>();
    state = await AsyncValue.guard(
      () => _load(
        current.copyWith(
          skill: skill?.apiValue,
          clearSkill: skill == null,
          page: 0,
        ),
      ),
    );
  }

  Future<void> updateSearch(String search) async {
    final current =
        state.valueOrNull?.resolvedQuery ?? const IeltsTestQueryParams();
    state = const AsyncLoading<IeltsListState>();
    state = await AsyncValue.guard(
      () => _load(
        current.copyWith(
          search: search,
          clearSearch: search.trim().isEmpty,
          page: 0,
        ),
      ),
    );
  }

  Future<void> goToPage(int page) async {
    final current =
        state.valueOrNull?.resolvedQuery ?? const IeltsTestQueryParams();
    if (page < 0 || page == current.page) {
      return;
    }

    state = const AsyncLoading<IeltsListState>();
    state = await AsyncValue.guard(() => _load(current.copyWith(page: page)));
  }

  Future<IeltsListState> _load(IeltsTestQueryParams query) async {
    final api = ref.read(ieltsApiProvider);
    final tests = await api.getTests(query);
    final highestScores = await api.getHighestScores(
      tests.items
          .map((item) => item.testId)
          .where((item) => item.isNotEmpty)
          .toList(),
    );
    final attempts = await api.getAttempts(
      skill: query.skill,
      limit: 24,
    );

    return IeltsListState(
      query: query,
      tests: PagedItems<IeltsTestSummary>(
        page: tests.page,
        size: tests.size,
        totalElements: tests.totalElements,
        totalPages: tests.totalPages,
        items: tests.items
            .map(
              (item) => item.copyWith(highestScore: highestScores[item.testId]),
            )
            .toList(growable: false),
      ),
      attempts: attempts,
    );
  }
}

final ieltsListControllerProvider =
    AutoDisposeAsyncNotifierProvider<IeltsListController, IeltsListState>(
      IeltsListController.new,
    );

class IeltsDetailBundle {
  const IeltsDetailBundle({
    required this.detail,
    required this.practiceOptions,
  });

  final IeltsTestDetail detail;
  final IeltsPracticeOptions practiceOptions;
}

final ieltsDetailProvider = FutureProvider.autoDispose
    .family<IeltsDetailBundle, String>((ref, testId) async {
      final api = ref.watch(ieltsApiProvider);
      final detail = await api.getTestDetail(testId);
      final options = await api.getPracticeOptions(
        testId,
        fallbackSkill: detail.skill,
      );
      return IeltsDetailBundle(detail: detail, practiceOptions: options);
    });

class IeltsSessionRuntime {
  const IeltsSessionRuntime({
    required this.attemptId,
    required this.detail,
    required this.answers,
    required this.startedAt,
    required this.activeSectionId,
    required this.focusedQuestionId,
    this.isSubmitting = false,
  });

  final String attemptId;
  final IeltsSessionDetail detail;
  final Map<String, List<String>> answers;
  final DateTime startedAt;
  final String activeSectionId;
  final String focusedQuestionId;
  final bool isSubmitting;

  int get answeredCount => answers.values
      .where((values) => values.any((value) => value.trim().isNotEmpty))
      .length;

  IeltsQuestion? get focusedQuestion {
    for (final section in detail.sections) {
      for (final question in section.questions) {
        if (question.questionId == focusedQuestionId) {
          return question;
        }
      }
    }
    return null;
  }

  List<IeltsQuestion> questionsForSection(String sectionId) {
    return detail.sections
        .where((section) => section.id == sectionId)
        .expand((section) => section.questions)
        .toList(growable: false);
  }

  IeltsSessionRuntime copyWith({
    Map<String, List<String>>? answers,
    String? activeSectionId,
    String? focusedQuestionId,
    bool? isSubmitting,
  }) {
    return IeltsSessionRuntime(
      attemptId: attemptId,
      detail: detail,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      activeSectionId: activeSectionId ?? this.activeSectionId,
      focusedQuestionId: focusedQuestionId ?? this.focusedQuestionId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final ieltsSessionDetailProvider = FutureProvider.autoDispose
    .family<IeltsSessionDetail, String>((ref, attemptId) async {
      return ref.watch(ieltsApiProvider).getSession(attemptId);
    });

class IeltsSessionController
    extends AutoDisposeFamilyNotifier<IeltsSessionRuntime, IeltsSessionDetail> {
  @override
  IeltsSessionRuntime build(IeltsSessionDetail arg) {
    final answers = <String, List<String>>{
      for (final question in arg.allQuestions)
        if (question.submittedAnswers.isNotEmpty)
          question.questionId: List<String>.from(question.submittedAnswers),
    };
    final preferredSection = arg.sections.firstWhere(
      (section) => section.questions.any(
        (question) => !(answers[question.questionId] ?? const <String>[])
            .any((value) => value.trim().isNotEmpty),
      ),
      orElse: () => arg.sections.first,
    );
    final preferredQuestion = preferredSection.questions.firstWhere(
      (question) => !(answers[question.questionId] ?? const <String>[])
          .any((value) => value.trim().isNotEmpty),
      orElse: () => preferredSection.questions.first,
    );
    return IeltsSessionRuntime(
      attemptId: arg.attemptId,
      detail: arg,
      answers: answers,
      startedAt: DateTime.now(),
      activeSectionId: preferredSection.id,
      focusedQuestionId: preferredQuestion.questionId,
    );
  }

  void selectSection(String sectionId) {
    final section = state.detail.sections.firstWhere(
      (item) => item.id == sectionId,
      orElse: () => state.detail.sections.first,
    );
    final questionId = section.questions.isEmpty
        ? state.focusedQuestionId
        : section.questions.first.questionId;
    state = state.copyWith(
      activeSectionId: section.id,
      focusedQuestionId: questionId,
    );
  }

  void focusQuestion(String sectionId, String questionId) {
    state = state.copyWith(
      activeSectionId: sectionId,
      focusedQuestionId: questionId,
    );
  }

  void selectSingleAnswer(String questionId, String answer) {
    state = state.copyWith(
      answers: <String, List<String>>{
        ...state.answers,
        questionId: [answer],
      },
    );
  }

  void toggleMultipleAnswer(String questionId, String answer) {
    final current = List<String>.from(state.answers[questionId] ?? const <String>[]);
    if (current.contains(answer)) {
      current.remove(answer);
    } else {
      current.add(answer);
    }
    state = state.copyWith(
      answers: <String, List<String>>{
        ...state.answers,
        questionId: current,
      },
    );
  }

  void updateSlotAnswer(String questionId, int slotIndex, String answer) {
    final current = List<String>.from(state.answers[questionId] ?? const <String>[]);
    while (current.length <= slotIndex) {
      current.add('');
    }
    current[slotIndex] = answer;
    state = state.copyWith(
      answers: <String, List<String>>{
        ...state.answers,
        questionId: current,
      },
    );
  }

  Future<IeltsAttemptDetail> submit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final duration = DateTime.now().difference(state.startedAt).inSeconds;
      final result = await ref
          .read(ieltsApiProvider)
          .submitSession(
            state.attemptId,
            IeltsSubmitPayload(
              timeSpentSeconds: duration,
              answers: state.answers.entries
                  .map(
                    (entry) => IeltsSubmitAnswer(
                      questionId: entry.key,
                      answers: entry.value,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}

final ieltsSessionControllerProvider = AutoDisposeNotifierProviderFamily<
  IeltsSessionController,
  IeltsSessionRuntime,
  IeltsSessionDetail
>(IeltsSessionController.new);

class IeltsResultBundle {
  const IeltsResultBundle({
    required this.attempt,
    this.transcript,
  });

  final IeltsAttemptDetail attempt;
  final IeltsTranscript? transcript;
}

final ieltsResultBundleProvider = FutureProvider.autoDispose
    .family<IeltsResultBundle, String>((ref, attemptId) async {
      final api = ref.watch(ieltsApiProvider);
      final attempt = await api.getAttemptDetail(attemptId);
      IeltsTranscript? transcript;
      if (attempt.isListening) {
        try {
          transcript = await api.getListeningTranscript(attemptId);
        } catch (_) {
          transcript = null;
        }
      }
      return IeltsResultBundle(attempt: attempt, transcript: transcript);
    });
