import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/network/api_error.dart';
import 'data/auth_api.dart';
import 'data/auth_session_manager.dart';
import 'data/auth_session_storage.dart';
import 'models/auth_models.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthApi authApi,
    required AuthSessionStorage storage,
    required AuthSessionManager sessionManager,
  })  : _authApi = authApi,
        _storage = storage,
        _sessionManager = sessionManager {
    _sessionManager.onSessionInvalidated = _handleSessionInvalidated;
    unawaited(_bootstrap());
  }

  final AuthApi _authApi;
  final AuthSessionStorage _storage;
  final AuthSessionManager _sessionManager;

  AuthStatus _status = AuthStatus.loading;
  AuthUser? _user;
  String? _errorMessage;
  bool _isSubmitting = false;

  AuthStatus get status => _status;

  AuthUser? get user => _user;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;

  bool get isRestoring => _status == AuthStatus.loading;

  bool get isSubmitting => _isSubmitting;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _runSubmission(() async {
      final result = await _authApi.login(
        email: email,
        password: password,
      );

      await _sessionManager.persistSession(result.session);
      await _storage.writeUser(result.user);
      _status = AuthStatus.authenticated;
      _user = result.user;
      _errorMessage = null;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await _runSubmission(() async {
      final result = await _authApi.register(
        email: email,
        password: password,
        displayName: displayName,
      );

      await _sessionManager.persistSession(result.session);
      await _storage.writeUser(result.user);
      _status = AuthStatus.authenticated;
      _user = result.user;
      _errorMessage = null;
    });
  }

  Future<void> logout() async {
    final currentRefreshToken = _sessionManager.refreshToken;
    if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
      unawaited(_authApi.logout(currentRefreshToken));
    }

    await _sessionManager.clearSession(reason: 'manual');
    await _storage.clearUser();
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final nextUser = await _authApi.getMe();
    await _storage.writeUser(nextUser);
    _status = AuthStatus.authenticated;
    _user = nextUser;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _bootstrap() async {
    await _storage.clearLegacyToken();

    final cachedUser = _storage.readUser();
    if (cachedUser != null) {
      _user = cachedUser;
      notifyListeners();
    }

    final restoredSession = await _sessionManager.restoreSession();

    if (!(restoredSession?.hasRefreshToken ?? false)) {
      await _storage.clearUser();
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    try {
      await _sessionManager.ensureValidAccessToken();
      final nextUser = await _authApi.getMe();
      await _storage.writeUser(nextUser);
      _status = AuthStatus.authenticated;
      _user = nextUser;
      _errorMessage = null;
    } on ApiError catch (error) {
      if (error.status == 401) {
        await _storage.clearUser();
        _status = AuthStatus.unauthenticated;
        _user = null;
        _errorMessage = null;
      } else {
        _status = cachedUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        _user = cachedUser;
        _errorMessage = error.message;
      }
    } catch (error) {
      _status = cachedUser != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      _user = cachedUser;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> _runSubmission(Future<void> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
    } on ApiError catch (error) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = error.message;
      rethrow;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = 'Something went wrong. Please try again.';
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _handleSessionInvalidated(String reason) async {
    await _storage.clearUser();
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = reason == 'expired'
        ? 'Your session has expired. Please sign in again.'
        : null;
    notifyListeners();
  }
}
