import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'leaderboard_models.dart';
import 'leaderboard_query_params.dart';
import 'xp_history_models.dart';

class LeaderboardApi {
  LeaderboardApi(this._client);

  final Dio _client;

  Future<LeaderboardSummaryResponse> getSummary() async {
    try {
      final response = await _client.get<Object?>('/leaderboard/summary');
      return LeaderboardSummaryResponse.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<LeaderboardResponse> getLeaderboard(
    LeaderboardQueryParams query,
  ) async {
    try {
      final response = await _client.get<Object?>(
        '/leaderboard',
        queryParameters: query.toQueryParameters(),
      );
      return LeaderboardResponse.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<XpHistoryResponse> getXpHistory({int page = 0, int size = 20}) async {
    try {
      final response = await _client.get<Object?>(
        '/xp/history',
        queryParameters: {'page': page, 'size': size},
      );
      return XpHistoryResponse.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
