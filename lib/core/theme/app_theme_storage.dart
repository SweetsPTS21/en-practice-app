import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/shared_preferences_provider.dart';
import 'theme_backgrounds.dart';
import 'theme_mode_prefs.dart';
import 'theme_profiles.dart';
import 'theme_solid_primary.dart';

const appThemePreferenceStorageKey = 'en_practice_theme_preference';
const appThemeBackgroundStorageKey = 'en_practice_theme_background';
const appThemeProfileStorageKey = 'en_practice_theme_profile';
const appThemeSolidPrimaryStorageKey = 'en_practice_theme_solid_primary';

final appThemeStorageProvider = Provider<AppThemeStorage>((ref) {
  return AppThemeStorage(ref.watch(sharedPreferencesProvider));
});

class AppThemeStorage {
  AppThemeStorage(this._preferences);

  final SharedPreferences _preferences;

  AppThemePreference readThemePreference() {
    return parseThemePreference(_preferences.getString(appThemePreferenceStorageKey));
  }

  AppThemeBackgroundPreference readThemeBackgroundPreference() {
    return parseThemeBackgroundPreference(
      _preferences.getString(appThemeBackgroundStorageKey),
    );
  }

  AppThemeProfilePreference readThemeProfilePreference() {
    return parseThemeProfilePreference(_preferences.getString(appThemeProfileStorageKey));
  }

  AppThemeSolidPrimaryPreference readThemeSolidPrimaryPreference() {
    return parseThemeSolidPrimaryPreference(
      _preferences.getString(appThemeSolidPrimaryStorageKey),
    );
  }

  Future<void> writeThemePreference(AppThemePreference value) async {
    await _preferences.setString(appThemePreferenceStorageKey, value.name);
  }

  Future<void> writeThemeBackgroundPreference(
    AppThemeBackgroundPreference value,
  ) async {
    await _preferences.setString(appThemeBackgroundStorageKey, value.name);
  }

  Future<void> writeThemeProfilePreference(AppThemeProfilePreference value) async {
    await _preferences.setString(appThemeProfileStorageKey, value.name);
  }

  Future<void> writeThemeSolidPrimaryPreference(
    AppThemeSolidPrimaryPreference value,
  ) async {
    await _preferences.setString(appThemeSolidPrimaryStorageKey, value.name);
  }
}
