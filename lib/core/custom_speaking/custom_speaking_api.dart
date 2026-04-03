import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import '../productive/paged_items.dart';
import 'custom_speaking_models.dart';

class CustomSpeakingApi {
  CustomSpeakingApi(this._client);

  final Dio _client;

  Future<CustomSpeakingStep> startConversation(
    StartCustomSpeakingPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/custom-speaking-conversations/start',
        data: payload.toJson(),
      );
      return CustomSpeakingStep.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<CustomSpeakingStep> submitTurn(
    String conversationId,
    SubmitCustomSpeakingTurnPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/custom-speaking-conversations/$conversationId/turn',
        data: payload.toJson(),
      );
      return CustomSpeakingStep.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<CustomSpeakingStep> finishConversation(String conversationId) async {
    try {
      final response = await _client.post<Object?>(
        '/custom-speaking-conversations/$conversationId/finish',
      );
      return CustomSpeakingStep.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<CustomSpeakingConversation> getConversation(
    String conversationId,
  ) async {
    try {
      final response = await _client.get<Object?>(
        '/custom-speaking-conversations/$conversationId',
      );
      return CustomSpeakingConversation.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<PagedItems<CustomSpeakingConversation>> getConversations({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/custom-speaking-conversations',
        queryParameters: <String, dynamic>{'page': page, 'size': size},
      );
      return PagedItems<CustomSpeakingConversation>.fromJson(
        jsonMap(response.data),
        itemBuilder: CustomSpeakingConversation.fromJson,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
