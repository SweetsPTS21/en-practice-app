import 'package:dio/dio.dart';

import '../network/api_error.dart';
import '../network/json_helpers.dart';
import 'dictionary_models.dart';
import 'dictionary_query_params.dart';

class DictionaryApi {
  DictionaryApi(this._client);

  final Dio _client;

  Future<DictionaryWordPage> searchWords(DictionaryQueryParams query) async {
    try {
      final response = await _client.get<Object?>(
        '/dictionary',
        queryParameters: query.toQueryParameters(),
      );
      return DictionaryWordPage.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<DictionaryStats> getStats() async {
    try {
      final response = await _client.get<Object?>('/dictionary/stats');
      return DictionaryStats.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<DictionaryWord> getWordById(String id) async {
    try {
      final response = await _client.get<Object?>('/dictionary/$id');
      return DictionaryWord.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<DictionaryWord> addWord(Map<String, dynamic> payload) async {
    try {
      final response = await _client.post<Object?>(
        '/dictionary',
        data: payload,
      );
      return DictionaryWord.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<DictionaryWord> toggleFavorite(String id) async {
    try {
      final response = await _client.patch<Object?>('/dictionary/$id/favorite');
      return DictionaryWord.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> deleteWord(String id) async {
    try {
      await _client.delete<Object?>('/dictionary/$id');
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<DictionaryWord> reviewWord(String id, int performanceScore) async {
    try {
      final response = await _client.patch<Object?>(
        '/dictionary/$id/review',
        data: {'performanceScore': performanceScore},
      );
      return DictionaryWord.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
