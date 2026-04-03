import 'package:dio/dio.dart';

import '../../../core/learning_journey/completion_snapshot_models.dart';
import '../../../core/network/api_error.dart';
import '../../../core/network/json_helpers.dart';
import 'result_snapshot_request.dart';

class CompletionSnapshotApi {
  CompletionSnapshotApi(this._client);

  final Dio _client;

  Future<CompletionSnapshot> getCompletionSnapshot(
    ResultSnapshotRequest request,
  ) async {
    try {
      final response = await _client.get<Object?>(request.endpointPath);
      return CompletionSnapshot.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
