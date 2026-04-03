import 'package:dio/dio.dart';

import '../network/api_error.dart';

class PushRegistrationApi {
  PushRegistrationApi(this._client);

  final Dio _client;

  Future<void> registerToken({
    required String token,
    required String os,
    String? browser,
  }) async {
    try {
      await _client.post<Object?>(
        '/auth/fcm-token',
        data: {'fcmToken': token, 'os': os, 'browser': browser},
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
