import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'recommendation_feedback_models.dart';
import 'recommendation_models.dart';
import 'recommendation_surface.dart';

class RecommendationApi {
  RecommendationApi(this._client);

  final Dio _client;

  Future<RecommendationCardModel?> getPrimary(RecommendationSurface surface) async {
    try {
      final response = await _client.get<Object?>(
        '/user/recommendations/primary',
        queryParameters: <String, dynamic>{
          'surface': surface.value,
        },
      );

      if (response.data == null) {
        return null;
      }

      final data = jsonMap(response.data);
      if (data.isEmpty) {
        return null;
      }

      return RecommendationCardModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw ApiError.fromDioException(error);
    }
  }

  Future<RecommendationFeed?> getFeed(RecommendationSurface surface) async {
    try {
      final response = await _client.get<Object?>(
        '/user/recommendations/feed',
        queryParameters: <String, dynamic>{
          'surface': surface.value,
        },
      );

      if (response.data == null) {
        return null;
      }

      final data = jsonMap(response.data);
      if (data.isEmpty) {
        return null;
      }

      return RecommendationFeed.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> submitFeedback(
    String recommendationKey,
    RecommendationFeedbackRequest request,
  ) async {
    try {
      await _client.post<Object?>(
        '/user/recommendations/$recommendationKey/feedback',
        data: request.toJson(),
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
