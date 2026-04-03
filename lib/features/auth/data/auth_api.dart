import 'package:dio/dio.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/json_helpers.dart';
import '../models/auth_models.dart';

class AuthApi {
  AuthApi(this._client);

  final Dio _client;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Object?>(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(extra: const {'skipAuthRefresh': true}),
      );

      return AuthResult.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.post<Object?>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
        options: Options(extra: const {'skipAuthRefresh': true}),
      );

      return AuthResult.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _client.post<Object?>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
        options: Options(extra: const {'skipAuthRefresh': true}),
      );
    } on DioException catch (_) {
      // Logout is best effort.
    }
  }

  Future<AuthUser> getMe() async {
    try {
      final response = await _client.get<Object?>('/auth/me');
      return AuthUser.fromJson(jsonMap(response.data));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<void> saveFcmToken({
    required String fcmToken,
    required String os,
    String? browser,
  }) async {
    try {
      await _client.post<Object?>(
        '/auth/fcm-token',
        data: {'fcmToken': fcmToken, 'os': os, 'browser': browser},
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}
