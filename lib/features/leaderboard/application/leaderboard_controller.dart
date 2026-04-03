import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/leaderboard/leaderboard_models.dart';
import '../../../core/leaderboard/leaderboard_providers.dart';
import '../../../core/leaderboard/leaderboard_query_params.dart';

class LeaderboardScreenState {
  const LeaderboardScreenState({
    required this.query,
    required this.response,
    this.isLoadingMore = false,
  });

  final LeaderboardQueryParams query;
  final LeaderboardResponse response;
  final bool isLoadingMore;

  bool get hasMore => response.hasMore;

  LeaderboardScreenState copyWith({
    LeaderboardQueryParams? query,
    LeaderboardResponse? response,
    bool? isLoadingMore,
  }) {
    return LeaderboardScreenState(
      query: query ?? this.query,
      response: response ?? this.response,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class LeaderboardController extends AutoDisposeAsyncNotifier<LeaderboardScreenState> {
  static const _defaultQuery = LeaderboardQueryParams();

  @override
  Future<LeaderboardScreenState> build() async {
    final api = ref.watch(leaderboardApiProvider);
    final response = await api.getLeaderboard(_defaultQuery);
    return LeaderboardScreenState(
      query: _defaultQuery,
      response: response,
    );
  }

  Future<void> refresh() async {
    await _replace(state.requireValue.query.copyWith(page: 0));
  }

  Future<void> updatePeriod(LeaderboardPeriod period) async {
    final current = state.requireValue.query;
    await _replace(
      current.copyWith(
        period: period,
        page: 0,
      ),
    );
  }

  Future<void> updateScope(LeaderboardScope scope) async {
    final current = state.requireValue.query;
    await _replace(
      current.copyWith(
        scope: scope,
        page: 0,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextQuery = current.query.copyWith(page: current.query.page + 1);
      final nextResponse = await ref.read(leaderboardApiProvider).getLeaderboard(nextQuery);
      state = AsyncData(
        current.copyWith(
          query: nextQuery,
          response: current.response.append(nextResponse),
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> _replace(LeaderboardQueryParams nextQuery) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(leaderboardApiProvider).getLeaderboard(nextQuery);
      return LeaderboardScreenState(
        query: nextQuery,
        response: response,
      );
    });
  }
}

final leaderboardControllerProvider =
    AutoDisposeAsyncNotifierProvider<LeaderboardController, LeaderboardScreenState>(
  LeaderboardController.new,
);
