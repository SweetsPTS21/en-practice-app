import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'achievement_models.dart';

class AchievementApi {
  AchievementApi(this._client);

  final Dio _client;

  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _client.get<Object?>('/user/achievements');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Object?>()
            .map((item) => Achievement.fromJson(jsonMap(item)))
            .toList(growable: false);
      }

      final map = jsonMap(data);
      final items = map['items'];
      if (items is! List) {
        return const <Achievement>[];
      }

      return items
          .whereType<Object?>()
          .map((item) => Achievement.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const <Achievement>[];
      }
      throw ApiError.fromDioException(error);
    }
  }
}
