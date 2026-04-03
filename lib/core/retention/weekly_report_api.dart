import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'weekly_report_models.dart';

class WeeklyReportApi {
  WeeklyReportApi(this._client);

  final Dio _client;

  Future<WeeklyReport?> getLatest() async {
    try {
      final response = await _client.get<Object?>('/user/reports/weekly/latest');
      if (response.data == null) {
        return null;
      }

      final data = jsonMap(response.data);
      if (data.isEmpty) {
        return null;
      }

      return WeeklyReport.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw ApiError.fromDioException(error);
    }
  }
}
