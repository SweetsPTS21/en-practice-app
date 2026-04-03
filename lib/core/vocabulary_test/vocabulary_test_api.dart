import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'vocabulary_test_models.dart';
import 'vocabulary_test_query_params.dart';

class VocabularyTestApi {
  VocabularyTestApi(this._client);

  final Dio _client;

  Future<VocabularyTestDetail> generate(
    VocabularyTestGeneratePayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/vocabulary-tests/generate',
        data: payload.toJson(),
      );
      return VocabularyTestDetail.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<List<VocabularyTestSummary>> getTests() async {
    try {
      final response = await _client.get<Object?>('/vocabulary-tests');
      final data = response.data;
      if (data is! List) {
        return const <VocabularyTestSummary>[];
      }
      return data
          .whereType<Object?>()
          .map((item) => VocabularyTestSummary.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<VocabularyTestDetail> getTestDetail(String id) async {
    try {
      final response = await _client.get<Object?>('/vocabulary-tests/$id');
      return VocabularyTestDetail.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<StartVocabularyTestResponse> startTest(String id) async {
    try {
      final response = await _client.post<Object?>(
        '/vocabulary-tests/$id/start',
      );
      return StartVocabularyTestResponse.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<VocabularyTestAttemptResult> submitAttempt(
    String attemptId,
    VocabularyTestSubmitPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/vocabulary-tests/attempts/$attemptId/submit',
        data: payload.toJson(),
      );
      return VocabularyTestAttemptResult.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<List<VocabularyTestAttemptHistoryItem>> getAttemptHistory(
    VocabularyTestAttemptQueryParams query,
  ) async {
    try {
      final response = await _client.get<Object?>(
        '/vocabulary-tests/attempts',
        queryParameters: query.toQueryParameters(),
      );
      final data = response.data;
      if (data is! List) {
        return const <VocabularyTestAttemptHistoryItem>[];
      }
      return data
          .whereType<Object?>()
          .map(
            (item) => VocabularyTestAttemptHistoryItem.fromJson(jsonMap(item)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<VocabularyTestAttemptResult> getAttemptDetail(String attemptId) async {
    try {
      final response = await _client.get<Object?>(
        '/vocabulary-tests/attempts/$attemptId',
      );
      return VocabularyTestAttemptResult.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
