import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/secure_store.dart';
import '../models/auth_models.dart';

class AuthSessionStorage {
  AuthSessionStorage(this._preferences, this._secureStore);

  final SharedPreferences _preferences;
  final SecureStore _secureStore;

  static const legacyTokenKey = 'en_practice_token';
  static const accessTokenKey = 'en_practice_access_token';
  static const refreshTokenKey = 'en_practice_refresh_token';
  static const accessTokenExpiresAtKey = 'en_practice_access_token_expires_at';
  static const refreshTokenExpiresAtKey =
      'en_practice_refresh_token_expires_at';
  static const userKey = 'en_practice_user';

  Future<AuthSession?> readSession() async {
    final accessToken = await _readToken(accessTokenKey);
    final refreshToken = await _readToken(refreshTokenKey);
    final legacyAccessToken = _preferences.getString(accessTokenKey);
    final legacyRefreshToken = _preferences.getString(refreshTokenKey);
    final resolvedAccessToken = accessToken ?? legacyAccessToken;
    final resolvedRefreshToken = refreshToken ?? legacyRefreshToken;

    if ((resolvedAccessToken == null || resolvedAccessToken.isEmpty) &&
        (resolvedRefreshToken == null || resolvedRefreshToken.isEmpty)) {
      return null;
    }

    final session = AuthSession(
      accessToken: resolvedAccessToken,
      refreshToken: resolvedRefreshToken,
      accessTokenExpiresAt: _preferences.getString(accessTokenExpiresAtKey),
      refreshTokenExpiresAt: _preferences.getString(refreshTokenExpiresAtKey),
    );

    if (legacyAccessToken != null || legacyRefreshToken != null) {
      await writeSession(session);
    }

    return session;
  }

  AuthUser? readUser() {
    final raw = _preferences.getString(userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is! Map) {
        throw const FormatException('Stored user is not a JSON object.');
      }
      return AuthUser.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      _preferences.remove(userKey);
      return null;
    }
  }

  Future<void> writeSession(AuthSession session) async {
    await clearLegacyToken();

    await _writeToken(accessTokenKey, session.accessToken);
    await _writeToken(refreshTokenKey, session.refreshToken);

    if (session.accessTokenExpiresAt != null &&
        session.accessTokenExpiresAt!.isNotEmpty) {
      await _preferences.setString(
        accessTokenExpiresAtKey,
        session.accessTokenExpiresAt!,
      );
    } else {
      await _preferences.remove(accessTokenExpiresAtKey);
    }

    if (session.refreshTokenExpiresAt != null &&
        session.refreshTokenExpiresAt!.isNotEmpty) {
      await _preferences.setString(
        refreshTokenExpiresAtKey,
        session.refreshTokenExpiresAt!,
      );
    } else {
      await _preferences.remove(refreshTokenExpiresAtKey);
    }
  }

  Future<void> writeUser(AuthUser? user) async {
    if (user == null) {
      await _preferences.remove(userKey);
      return;
    }

    await _preferences.setString(userKey, json.encode(user.toJson()));
  }

  Future<void> clearSession() async {
    await clearLegacyToken();
    await _deleteToken(accessTokenKey);
    await _deleteToken(refreshTokenKey);
    await _preferences.remove(accessTokenExpiresAtKey);
    await _preferences.remove(refreshTokenExpiresAtKey);
  }

  Future<void> clearUser() async {
    await _preferences.remove(userKey);
  }

  Future<void> clearLegacyToken() async {
    await _preferences.remove(legacyTokenKey);
  }

  Future<String?> _readToken(String key) async {
    try {
      return await _secureStore.read(key);
    } on MissingPluginException {
      return _preferences.getString(key);
    }
  }

  Future<void> _writeToken(String key, String? value) async {
    try {
      await _secureStore.write(key, value);
      await _preferences.remove(key);
    } on MissingPluginException {
      if (value == null || value.isEmpty) {
        await _preferences.remove(key);
        return;
      }

      await _preferences.setString(key, value);
    }
  }

  Future<void> _deleteToken(String key) async {
    try {
      await _secureStore.delete(key);
    } on MissingPluginException {
      // Fall through to SharedPreferences cleanup below.
    }

    await _preferences.remove(key);
  }
}
