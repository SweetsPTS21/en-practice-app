import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import '../productive/paged_items.dart';
import 'writing_models.dart';
import 'writing_query_params.dart';

class WritingApi {
  WritingApi(this._client);

  final Dio _client;

  Future<PagedItems<WritingTaskSummary>> getTasks(
    WritingTaskQueryParams params,
  ) async {
    try {
      final response = await _client.get<Object?>(
        '/writing/tasks',
        queryParameters: params.toQueryParameters(),
      );
      return PagedItems<WritingTaskSummary>.fromJson(
        jsonMap(response.data),
        itemBuilder: WritingTaskSummary.fromJson,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<WritingTaskDetail> getTaskById(String taskId) async {
    try {
      final response = await _client.get<Object?>('/writing/tasks/$taskId');
      return WritingTaskDetail.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<List<WritingHighestScore>> getHighestScores(
    List<String> taskIds,
  ) async {
    if (taskIds.isEmpty) {
      return const <WritingHighestScore>[];
    }

    try {
      final response = await _client.post<Object?>(
        '/writing/tasks/highest-scores',
        data: <String, dynamic>{'taskIds': taskIds},
      );
      final data = response.data;
      if (data is! List) {
        return const <WritingHighestScore>[];
      }

      return data
          .whereType<Object?>()
          .map((item) => WritingHighestScore.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<WritingSubmission> submitEssay(
    String taskId,
    SubmitWritingPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/writing/tasks/$taskId/submit',
        data: payload.toJson(),
      );
      return WritingSubmission.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<PagedItems<WritingSubmission>> getSubmissions({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/writing/submissions',
        queryParameters: <String, dynamic>{'page': page, 'size': size},
      );
      return PagedItems<WritingSubmission>.fromJson(
        jsonMap(response.data),
        itemBuilder: WritingSubmission.fromJson,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<WritingSubmission> getSubmissionById(String submissionId) async {
    try {
      final response = await _client.get<Object?>(
        '/writing/submissions/$submissionId',
      );
      return WritingSubmission.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
