import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import '../productive/paged_items.dart';
import 'speaking_models.dart';
import 'speaking_query_params.dart';

class SpeakingApi {
  SpeakingApi(this._client);

  final Dio _client;

  Future<PagedItems<SpeakingTopicSummary>> getTopics(
    SpeakingTopicQueryParams params,
  ) async {
    try {
      final response = await _client.get<Object?>(
        '/speaking/topics',
        queryParameters: params.toQueryParameters(),
      );
      return PagedItems<SpeakingTopicSummary>.fromJson(
        jsonMap(response.data),
        itemBuilder: SpeakingTopicSummary.fromJson,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<SpeakingTopicDetail> getTopicById(String topicId) async {
    try {
      final response = await _client.get<Object?>('/speaking/topics/$topicId');
      return SpeakingTopicDetail.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<List<SpeakingHighestScore>> getHighestScores(
    List<String> topicIds,
  ) async {
    if (topicIds.isEmpty) {
      return const <SpeakingHighestScore>[];
    }

    try {
      final response = await _client.post<Object?>(
        '/speaking/topics/highest-scores',
        data: <String, dynamic>{'topicIds': topicIds},
      );
      final data = response.data;
      if (data is! List) {
        return const <SpeakingHighestScore>[];
      }

      return data
          .whereType<Object?>()
          .map((item) => SpeakingHighestScore.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<SpeakingAttempt> submitAttempt(
    String topicId,
    SubmitSpeakingPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/speaking/topics/$topicId/submit',
        data: payload.toJson(),
      );
      return SpeakingAttempt.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<PagedItems<SpeakingAttempt>> getAttempts({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/speaking/attempts',
        queryParameters: <String, dynamic>{'page': page, 'size': size},
      );
      return PagedItems<SpeakingAttempt>.fromJson(
        jsonMap(response.data),
        itemBuilder: SpeakingAttempt.fromJson,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<SpeakingAttempt> getAttemptById(String attemptId) async {
    try {
      final response = await _client.get<Object?>(
        '/speaking/attempts/$attemptId',
      );
      return SpeakingAttempt.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<String> uploadAudio(FormData formData) async {
    try {
      final response = await _client.post<Object?>(
        '/speaking/upload-audio',
        data: formData,
      );
      return response.data?.toString() ?? '';
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
