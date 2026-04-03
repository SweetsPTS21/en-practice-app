import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'weekly_challenge_models.dart';

class WeeklyChallengeApi {
  WeeklyChallengeApi(this._client);

  final Dio _client;

  Future<WeeklyChallenge?> getCurrentWeekly() async {
    try {
      final response = await _client.get<Object?>('/user/challenges/weekly/current');
      if (response.data == null) {
        return null;
      }

      final data = jsonMap(response.data);
      if (data.isEmpty) {
        return null;
      }

      return WeeklyChallenge.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw ApiError.fromDioException(error);
    }
  }
}
