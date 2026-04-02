import 'package:dio/dio.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/json_helpers.dart';
import 'home_launchpad_models.dart';

class DashboardApi {
  DashboardApi(this._client);

  final Dio _client;

  Future<ContinueLearningItem> getContinueLearning() async {
    try {
      final response = await _client.get<Object?>('/user/dashboard/continue-learning');
      return ContinueLearningItem.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<DailyLearningPlan> getDailyLearningPlan() async {
    try {
      final response = await _client.get<Object?>('/user/dashboard/daily-learning-plan');
      return DailyLearningPlan.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<List<QuickPracticeItem>> getQuickPractice() async {
    try {
      final response = await _client.get<Object?>('/user/dashboard/quick-practice');
      final data = jsonMap(response.data);
      final items = data['items'];
      if (items is! List) {
        return const <QuickPracticeItem>[];
      }

      return items
          .whereType<Object?>()
          .map((item) => QuickPracticeItem.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<ProgressSnapshot> getProgressSnapshot() async {
    try {
      final response = await _client.get<Object?>('/user/dashboard/progress-snapshot');
      return ProgressSnapshot.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
