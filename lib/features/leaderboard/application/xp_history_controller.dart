import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/leaderboard/leaderboard_providers.dart';
import '../../../core/leaderboard/xp_history_models.dart';

class XpHistoryScreenState {
  const XpHistoryScreenState({
    required this.response,
    this.page = 0,
    this.pageSize = 20,
    this.isLoadingMore = false,
  });

  final XpHistoryResponse response;
  final int page;
  final int pageSize;
  final bool isLoadingMore;

  bool get hasMore => response.hasMore;

  XpHistoryScreenState copyWith({
    XpHistoryResponse? response,
    int? page,
    int? pageSize,
    bool? isLoadingMore,
  }) {
    return XpHistoryScreenState(
      response: response ?? this.response,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class XpHistoryController extends AutoDisposeAsyncNotifier<XpHistoryScreenState> {
  @override
  Future<XpHistoryScreenState> build() async {
    final api = ref.watch(leaderboardApiProvider);
    final response = await api.getXpHistory();
    return XpHistoryScreenState(response: response);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(leaderboardApiProvider).getXpHistory();
      return XpHistoryScreenState(response: response);
    });
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final nextResponse = await ref.read(leaderboardApiProvider).getXpHistory(
            page: nextPage,
            size: current.pageSize,
          );
      state = AsyncData(
        current.copyWith(
          page: nextPage,
          response: current.response.append(nextResponse),
          isLoadingMore: false,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final xpHistoryControllerProvider =
    AutoDisposeAsyncNotifierProvider<XpHistoryController, XpHistoryScreenState>(
  XpHistoryController.new,
);
