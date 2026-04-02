import 'package:dio/dio.dart';

class ApiError implements Exception {
  const ApiError({
    required this.message,
    required this.status,
    this.data,
  });

  final String message;
  final int status;
  final Object? data;

  factory ApiError.fromDioException(DioException error) {
    if (error.error is ApiError) {
      return error.error! as ApiError;
    }

    final response = error.response;
    if (response == null) {
      final timedOut = error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;

      return ApiError(
        message: timedOut
            ? 'Request timeout. Please check your connection and try again.'
            : 'Unable to connect to the server. Please try again.',
        status: 0,
      );
    }

    final status = response.statusCode ?? 0;
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final bodyMessage = body is Map
        ? (body['message'] ?? body['error'])?.toString().trim()
        : null;

    if (status == 401) {
      return ApiError(
        message: bodyMessage ?? 'Your session has expired. Please sign in again.',
        status: 401,
        data: data,
      );
    }

    if (status == 403) {
      return ApiError(
        message: bodyMessage ?? 'You do not have permission to access this resource.',
        status: 403,
        data: data,
      );
    }

    if (status == 422) {
      return ApiError(
        message: bodyMessage ?? 'The submitted data is invalid.',
        status: 422,
        data: data,
      );
    }

    if (status >= 500) {
      return ApiError(
        message: bodyMessage ?? 'The server is having trouble right now. Please try again later.',
        status: status,
        data: data,
      );
    }

    return ApiError(
      message: bodyMessage ?? 'Request failed ($status).',
      status: status,
      data: data,
    );
  }

  @override
  String toString() => 'ApiError(status: $status, message: $message)';
}
