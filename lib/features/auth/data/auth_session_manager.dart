import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/json_helpers.dart';
import '../models/auth_models.dart';
import 'auth_session_storage.dart';

typedef AuthSessionInvalidatedCallback = FutureOr<void> Function(String reason);

class AuthSessionManager {
  AuthSessionManager({
    required AuthSessionStorage storage,
    required Dio refreshClient,
  })  : _storage = storage,
        _refreshClient = refreshClient;

  final AuthSessionStorage _storage;
  final Dio _refreshClient;

  AuthSessionInvalidatedCallback? onSessionInvalidated;
  AuthSession? _session;
  Future<AuthSession>? _refreshOperation;

  static const _expirySkew = Duration(seconds: 30);

  AuthSession? get session => _session;

  String? get accessToken => session?.accessToken;

  String? get refreshToken => session?.refreshToken;

  bool get hasRefreshToken => session?.hasRefreshToken ?? false;

  bool isTokenExpired(String? expiresAt, {Duration skew = _expirySkew}) {
    if (expiresAt == null || expiresAt.isEmpty) {
      return true;
    }

    final expiresAtDate = DateTime.tryParse(expiresAt);
    if (expiresAtDate == null) {
      return true;
    }

    return !expiresAtDate.isAfter(DateTime.now().add(skew));
  }

  Future<AuthSession?> restoreSession() async {
    _session ??= await _storage.readSession();
    return _session;
  }

  Future<void> persistSession(AuthSession session) async {
    _session = session;
    await _storage.writeSession(session);
  }

  Future<String?> ensureValidAccessToken() async {
    final currentSession = await restoreSession();
    if (currentSession != null &&
        currentSession.hasAccessToken &&
        !isTokenExpired(currentSession.accessTokenExpiresAt)) {
      return currentSession.accessToken;
    }

    if (!hasRefreshToken) {
      return null;
    }

    final refreshedSession = await refreshAccessToken();
    return refreshedSession.accessToken;
  }

  Future<AuthSession> refreshAccessToken() {
    final inFlight = _refreshOperation;
    if (inFlight != null) {
      return inFlight;
    }

    final completer = Completer<AuthSession>();
    _refreshOperation = completer.future;

    () async {
      try {
        final refreshedSession = await _requestRefreshToken();
        completer.complete(refreshedSession);
      } catch (error, stackTrace) {
        await clearSession(reason: 'expired');
        completer.completeError(error, stackTrace);
      } finally {
        _refreshOperation = null;
      }
    }();

    return completer.future;
  }

  Future<void> clearSession({String reason = 'manual'}) async {
    _session = null;
    await _storage.clearSession();
    final callback = onSessionInvalidated;
    if (callback != null) {
      await callback(reason);
    }
  }

  Future<AuthSession> _requestRefreshToken() async {
    final currentSession = await restoreSession();
    if (currentSession == null ||
        !currentSession.hasRefreshToken ||
        isTokenExpired(currentSession.refreshTokenExpiresAt, skew: Duration.zero)) {
      throw const ApiError(
        message: 'Your session has expired. Please sign in again.',
        status: 401,
      );
    }

    final response = await _refreshClient.post<Object?>(
      '/auth/refresh',
      data: {
        'refreshToken': currentSession.refreshToken,
      },
      options: Options(
        extra: const {
          'skipAuthRefresh': true,
          'skipAuthorization': true,
        },
      ),
    );

    final data = jsonMap(response.data);
    final refreshedSession = AuthSession(
      accessToken: data['accessToken']?.toString(),
      refreshToken: data['refreshToken']?.toString() ?? currentSession.refreshToken,
      accessTokenExpiresAt:
          data['accessTokenExpiresAt']?.toString() ?? currentSession.accessTokenExpiresAt,
      refreshTokenExpiresAt: data['refreshTokenExpiresAt']?.toString() ??
          currentSession.refreshTokenExpiresAt,
    );

    _session = refreshedSession;
    await _storage.writeSession(refreshedSession);
    return refreshedSession;
  }
}
