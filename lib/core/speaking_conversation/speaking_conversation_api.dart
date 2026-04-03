import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import '../productive/paged_items.dart';
import 'speaking_conversation_models.dart';

class SpeakingConversationApi {
  SpeakingConversationApi(this._client);

  final Dio _client;

  Future<SpeakingConversationNextStep> startConversation(String topicId) async {
    try {
      final response = await _client.post<Object?>(
        '/speaking/conversations/start',
        queryParameters: <String, dynamic>{'topicId': topicId},
      );
      return SpeakingConversationNextStep.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<SpeakingConversationNextStep> submitTurn(
    String conversationId,
    SubmitSpeakingConversationTurnPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/speaking/conversations/$conversationId/turn',
        data: payload.toJson(),
      );
      return SpeakingConversationNextStep.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<SpeakingConversation> getConversation(String conversationId) async {
    try {
      final response = await _client.get<Object?>(
        '/speaking/conversations/$conversationId',
      );
      return SpeakingConversation.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<PagedItems<SpeakingConversation>> getConversations({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/speaking/conversations',
        queryParameters: <String, dynamic>{'page': page, 'size': size},
      );
      return PagedItems<SpeakingConversation>.fromJson(
        jsonMap(response.data),
        itemBuilder: SpeakingConversation.fromJson,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
