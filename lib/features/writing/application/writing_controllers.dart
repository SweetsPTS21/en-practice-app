import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/productive/paged_items.dart';
import '../../../core/storage/shared_preferences_provider.dart';
import '../../../core/writing/writing_models.dart';
import '../../../core/writing/writing_providers.dart';
import '../../../core/writing/writing_query_params.dart';

const writingTaskTypeOptions = <String>['TASK_1', 'TASK_2', 'GENERAL'];
const writingDifficultyOptions = <String>['EASY', 'MEDIUM', 'HARD'];

class WritingListState {
  const WritingListState({
    required this.query,
    required this.tasks,
    required this.highestScores,
  });

  final WritingTaskQueryParams query;
  final PagedItems<WritingTaskSummary> tasks;
  final Map<String, WritingHighestScore> highestScores;

  WritingHighestScore? highestScoreFor(String taskId) => highestScores[taskId];
}

class WritingListController extends AutoDisposeAsyncNotifier<WritingListState> {
  @override
  Future<WritingListState> build() {
    return _load(const WritingTaskQueryParams());
  }

  Future<void> refresh() async {
    final currentQuery =
        state.valueOrNull?.query ?? const WritingTaskQueryParams();
    state = const AsyncLoading();
    state = AsyncData(await _load(currentQuery));
  }

  Future<void> updateTaskType(String? taskType) async {
    final current = state.valueOrNull?.query ?? const WritingTaskQueryParams();
    state = const AsyncLoading();
    state = AsyncData(
      await _load(
        current.copyWith(
          taskType: taskType == 'ALL' ? null : taskType,
          page: 0,
        ),
      ),
    );
  }

  Future<void> updateDifficulty(String? difficulty) async {
    final current = state.valueOrNull?.query ?? const WritingTaskQueryParams();
    state = const AsyncLoading();
    state = AsyncData(
      await _load(
        current.copyWith(
          difficulty: difficulty == 'ALL' ? null : difficulty,
          page: 0,
        ),
      ),
    );
  }

  Future<void> goToPage(int page) async {
    final current = state.valueOrNull?.query ?? const WritingTaskQueryParams();
    if (page < 0 || page == current.page) {
      return;
    }

    state = const AsyncLoading();
    state = AsyncData(await _load(current.copyWith(page: page)));
  }

  Future<WritingListState> _load(WritingTaskQueryParams query) async {
    final api = ref.read(writingApiProvider);
    final tasks = await api.getTasks(query);
    final highestScores = await api.getHighestScores(
      tasks.items.map((item) => item.id).toList(growable: false),
    );

    return WritingListState(
      query: query,
      tasks: tasks,
      highestScores: <String, WritingHighestScore>{
        for (final item in highestScores) item.taskId: item,
      },
    );
  }
}

final writingListControllerProvider =
    AutoDisposeAsyncNotifierProvider<WritingListController, WritingListState>(
      WritingListController.new,
    );

final writingTaskDetailProvider = FutureProvider.autoDispose
    .family<WritingTaskDetail, String>((ref, taskId) {
      return ref.watch(writingApiProvider).getTaskById(taskId);
    });

final writingTaskHighestScoreProvider = FutureProvider.autoDispose
    .family<WritingHighestScore?, String>((ref, taskId) async {
      final scores = await ref.watch(writingApiProvider).getHighestScores([
        taskId,
      ]);
      if (scores.isEmpty) {
        return null;
      }
      return scores.first;
    });

final writingSubmissionHistoryProvider =
    FutureProvider.autoDispose<PagedItems<WritingSubmission>>((ref) {
      return ref.watch(writingApiProvider).getSubmissions();
    });

class WritingDraftState {
  const WritingDraftState({required this.essay, this.lastSavedAt});

  final String essay;
  final DateTime? lastSavedAt;
}

class WritingDraftController
    extends AutoDisposeFamilyNotifier<WritingDraftState, String> {
  @override
  WritingDraftState build(String taskId) {
    final preferences = ref.watch(sharedPreferencesProvider);
    final essay = preferences.getString(_draftKey(taskId)) ?? '';
    final lastSavedMs = preferences.getInt(_savedAtKey(taskId));

    return WritingDraftState(
      essay: essay,
      lastSavedAt: lastSavedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastSavedMs),
    );
  }

  Future<void> updateEssay(String essay) async {
    final preferences = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    await preferences.setString(_draftKey(arg), essay);
    await preferences.setInt(_savedAtKey(arg), now.millisecondsSinceEpoch);

    state = WritingDraftState(essay: essay, lastSavedAt: now);
  }

  Future<void> clear() async {
    final preferences = ref.read(sharedPreferencesProvider);
    await preferences.remove(_draftKey(arg));
    await preferences.remove(_savedAtKey(arg));
    state = const WritingDraftState(essay: '');
  }

  String _draftKey(String taskId) => 'writing.draft.$taskId';
  String _savedAtKey(String taskId) => 'writing.draft.savedAt.$taskId';
}

final writingDraftControllerProvider = NotifierProvider.autoDispose
    .family<WritingDraftController, WritingDraftState, String>(
      WritingDraftController.new,
    );
