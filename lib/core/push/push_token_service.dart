import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_platform_adapter.dart';
import 'push_registration_api.dart';

class PushTokenService {
  PushTokenService({
    required SharedPreferences preferences,
    required PushPlatformAdapter adapter,
    required PushRegistrationApi registrationApi,
  }) : _preferences = preferences,
       _adapter = adapter,
       _registrationApi = registrationApi;

  final SharedPreferences _preferences;
  final PushPlatformAdapter _adapter;
  final PushRegistrationApi _registrationApi;

  static const _lastSyncedTokenKey = 'push.lastSyncedToken';

  Future<void> syncTokenIfPossible({bool force = false}) async {
    final permission = await _adapter.getCurrentPermissionStatus();
    if (permission != PushPermissionStatus.granted) {
      return;
    }

    final token = await _adapter.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final lastSyncedToken = _preferences.getString(_lastSyncedTokenKey);
    if (!force && lastSyncedToken == token) {
      return;
    }

    await _registrationApi.registerToken(
      token: token,
      os: _platformName(),
      browser: defaultTargetPlatform.name,
    );
    await _preferences.setString(_lastSyncedTokenKey, token);
  }

  Future<void> clearCachedToken() async {
    await _preferences.remove(_lastSyncedTokenKey);
  }

  String _platformName() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ANDROID',
      TargetPlatform.iOS => 'IOS',
      TargetPlatform.macOS => 'MACOS',
      TargetPlatform.windows => 'WINDOWS',
      TargetPlatform.linux => 'LINUX',
      TargetPlatform.fuchsia => 'FUCHSIA',
    };
  }
}
