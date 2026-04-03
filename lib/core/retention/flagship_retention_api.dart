import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'flagship_retention_models.dart';

class FlagshipRetentionApi {
  FlagshipRetentionApi(this._client);

  final Dio _client;

  Future<FlagshipRetention?> getFlagshipRetention() async {
    try {
      final response = await _client.get<Object?>('/user/dashboard/flagship-retention');
      if (response.data == null) {
        return null;
      }

      final data = jsonMap(response.data);
      if (data.isEmpty) {
        return null;
      }

      return FlagshipRetention.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw ApiError.fromDioException(error);
    }
  }
}
