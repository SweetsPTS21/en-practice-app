import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/productive/paged_items.dart';
import '../../../core/speaking/speaking_models.dart';
import '../../../core/speaking/speaking_providers.dart';
import '../../../core/speaking/speaking_query_params.dart';

const speakingPartOptions = <String>['PART_1', 'PART_2', 'PART_3'];
const speakingDifficultyOptions = <String>['EASY', 'MEDIUM', 'HARD'];

class SpeakingListState {
  const SpeakingListState({
    required this.query,
    required this.topics,
    required this.highestScores,
  });

  final SpeakingTopicQueryParams query;
  final PagedItems<SpeakingTopicSummary> topics;
  final Map<String, SpeakingHighestScore> highestScores;

  SpeakingHighestScore? highestScoreFor(String topicId) =>
      highestScores[topicId];
}

class SpeakingListController
    extends AutoDisposeAsyncNotifier<SpeakingListState> {
  @override
  Future<SpeakingListState> build() {
    return _load(const SpeakingTopicQueryParams());
  }

  Future<void> refresh() async {
    final current =
        state.valueOrNull?.query ?? const SpeakingTopicQueryParams();
    state = const AsyncLoading();
    state = AsyncData(await _load(current));
  }

  Future<void> updatePart(String? part) async {
    final current =
        state.valueOrNull?.query ?? const SpeakingTopicQueryParams();
    state = const AsyncLoading();
    state = AsyncData(
      await _load(current.copyWith(part: part == 'ALL' ? null : part)),
    );
  }

  Future<void> updateDifficulty(String? difficulty) async {
    final current =
        state.valueOrNull?.query ?? const SpeakingTopicQueryParams();
    state = const AsyncLoading();
    state = AsyncData(
      await _load(
        current.copyWith(difficulty: difficulty == 'ALL' ? null : difficulty),
      ),
    );
  }

  Future<SpeakingListState> _load(SpeakingTopicQueryParams query) async {
    final api = ref.read(speakingApiProvider);
    final topics = await api.getTopics(query);
    final highestScores = await api.getHighestScores(
      topics.items.map((item) => item.id).toList(growable: false),
    );

    return SpeakingListState(
      query: query,
      topics: topics,
      highestScores: <String, SpeakingHighestScore>{
        for (final item in highestScores) item.topicId: item,
      },
    );
  }
}

final speakingListControllerProvider =
    AutoDisposeAsyncNotifierProvider<SpeakingListController, SpeakingListState>(
      SpeakingListController.new,
    );

final speakingTopicDetailProvider = FutureProvider.autoDispose
    .family<SpeakingTopicDetail, String>((ref, topicId) {
      return ref.watch(speakingApiProvider).getTopicById(topicId);
    });

final speakingTopicHighestScoreProvider = FutureProvider.autoDispose
    .family<SpeakingHighestScore?, String>((ref, topicId) async {
      final scores = await ref.watch(speakingApiProvider).getHighestScores([
        topicId,
      ]);
      if (scores.isEmpty) {
        return null;
      }
      return scores.first;
    });

final speakingAttemptHistoryProvider =
    FutureProvider.autoDispose<PagedItems<SpeakingAttempt>>((ref) {
      return ref.watch(speakingApiProvider).getAttempts();
    });
