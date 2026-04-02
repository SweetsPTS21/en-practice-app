import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/shared_preferences_provider.dart';

const appLanguageStorageKey = 'en_practice_language';

final appLocaleStorageProvider = Provider<AppLocaleStorage>((ref) {
  return AppLocaleStorage(ref.watch(sharedPreferencesProvider));
});

class AppLocaleStorage {
  AppLocaleStorage(this._preferences);

  final SharedPreferences _preferences;

  String? readLanguageCode() => _preferences.getString(appLanguageStorageKey);

  Future<void> writeLanguageCode(String languageCode) async {
    await _preferences.setString(appLanguageStorageKey, languageCode);
  }
}
