import 'package:dio/dio.dart';

import '../../features/auth/data/auth_session_manager.dart';
import 'api_config.dart';
import 'api_error.dart';
import 'json_helpers.dart';

const _skipAuthRefreshKey = 'skipAuthRefresh';
const _skipAuthorizationKey = 'skipAuthorization';
const _retryRequestKey = 'retryAuthRequest';

Dio createPublicApiClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      headers: ApiConfig.headers,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        try {
          response.data = _unwrapApiBody(
            response.data,
            fallbackStatus: response.statusCode ?? 200,
          );
          handler.next(response);
        } on ApiError catch (error) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: error,
              message: error.message,
            ),
          );
        }
      },
      onError: (error, handler) {
        handler.next(_normalizeError(error));
      },
    ),
  );

  return dio;
}

Dio createAuthorizedApiClient({required AuthSessionManager sessionManager}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      headers: ApiConfig.headers,
    ),
  );

  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          if (!_shouldSkipRefresh(options) && sessionManager.hasRefreshToken) {
            final token = await sessionManager.ensureValidAccessToken();
            if (token != null && !_shouldSkipAuthorization(options)) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else if (!_shouldSkipAuthorization(options)) {
            final token = sessionManager.accessToken;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        } catch (error) {
          handler.reject(
            error is DioException
                ? _normalizeError(error)
                : DioException(
                    requestOptions: options,
                    type: DioExceptionType.unknown,
                    error: error,
                    message: error.toString(),
                  ),
          );
        }
      },
      onResponse: (response, handler) {
        try {
          response.data = _unwrapApiBody(
            response.data,
            fallbackStatus: response.statusCode ?? 200,
          );
          handler.next(response);
        } on ApiError catch (error) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: error,
              message: error.message,
            ),
          );
        }
      },
      onError: (error, handler) async {
        final status = error.response?.statusCode;
        final requestOptions = error.requestOptions;

        if (status == 401 &&
            requestOptions.extra[_retryRequestKey] != true &&
            !_shouldSkipRefresh(requestOptions) &&
            sessionManager.hasRefreshToken) {
          requestOptions.extra[_retryRequestKey] = true;

          try {
            final refreshedSession = await sessionManager.refreshAccessToken();
            final token = refreshedSession.accessToken;

            if (token != null && token.isNotEmpty) {
              requestOptions.headers['Authorization'] = 'Bearer $token';
            }

            final retriedResponse = await dio.fetch<dynamic>(requestOptions);
            handler.resolve(retriedResponse);
            return;
          } catch (_) {
            // Let the normalized 401 below drive the logout state.
          }
        }

        if (status == 401) {
          await sessionManager.clearSession(reason: 'expired');
        }

        handler.next(_normalizeError(error));
      },
    ),
  );

  return dio;
}

Object? _unwrapApiBody(Object? body, {required int fallbackStatus}) {
  if (body is! Map || !body.containsKey('success')) {
    return body;
  }

  final data = jsonMap(body);
  if (data['success'] == true) {
    return data['data'];
  }

  throw ApiError(
    message: (data['message']?.toString().trim().isNotEmpty ?? false)
        ? data['message'].toString()
        : 'Request failed.',
    status: fallbackStatus,
    data: data['data'],
  );
}

bool _shouldSkipRefresh(RequestOptions options) {
  final url = options.path;
  return options.extra[_skipAuthRefreshKey] == true ||
      url.contains('/auth/login') ||
      url.contains('/auth/register') ||
      url.contains('/auth/refresh') ||
      url.contains('/auth/logout');
}

bool _shouldSkipAuthorization(RequestOptions options) {
  return options.extra[_skipAuthorizationKey] == true;
}

DioException _normalizeError(DioException error) {
  final apiError = ApiError.fromDioException(error);
  return error.copyWith(error: apiError, message: apiError.message);
}
