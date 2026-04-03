import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'review_models.dart';

class ReviewApi {
  ReviewApi(this._client);

  final Dio _client;

  Future<List<ReviewWord>> getReviewWords({
    required ReviewFilter filter,
    required int limit,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/records/review-words',
        queryParameters: {
          'filter': filter.name,
          'limit': limit,
        },
      );
      final data = response.data;
      if (data is! List) {
        return const <ReviewWord>[];
      }
      return data
          .whereType<Object?>()
          .map((item) => ReviewWord.fromJson(jsonMap(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<ReviewCounts> getReviewCounts() async {
    try {
      final response = await _client.get<Object?>('/records/review-counts');
      return ReviewCounts.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<ReviewSessionSummary> submitReviewSession(ReviewSessionPayload payload) async {
    try {
      final response = await _client.post<Object?>(
        '/reviews',
        data: payload.toJson(),
      );
      return ReviewSessionSummary.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
