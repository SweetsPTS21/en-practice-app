import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme_state.dart';
import 'app_theme_storage.dart';
import 'theme_backgrounds.dart';
import 'theme_mode_prefs.dart';
import 'theme_profiles.dart';
import 'theme_resolver.dart';
import 'theme_solid_primary.dart';

final appThemeControllerProvider =
    NotifierProvider<AppThemeController, AppThemeState>(AppThemeController.new);

class AppThemeController extends Notifier<AppThemeState> {
  late final AppThemeStorage _storage;

  @override
  AppThemeState build() {
    _storage = ref.watch(appThemeStorageProvider);

    return resolveAppThemeState(
      themePreference: _storage.readThemePreference(),
      themeBackgroundPreference: _storage.readThemeBackgroundPreference(),
      themeProfilePreference: _storage.readThemeProfilePreference(),
      themeSolidPrimaryPreference: _storage.readThemeSolidPrimaryPreference(),
      systemBrightness: PlatformDispatcher.instance.platformBrightness,
    );
  }

  Future<void> initialize() async {}

  Future<void> setThemePreference(AppThemePreference value) async {
    await _storage.writeThemePreference(value);
    state = resolveAppThemeState(
      themePreference: value,
      themeBackgroundPreference: state.themeBackgroundPreference,
      themeProfilePreference: state.themeProfilePreference,
      themeSolidPrimaryPreference: state.themeSolidPrimaryPreference,
      systemBrightness: state.systemBrightness,
    );
  }

  Future<void> setThemeBackgroundPreference(
    AppThemeBackgroundPreference value,
  ) async {
    await _storage.writeThemeBackgroundPreference(value);
    state = resolveAppThemeState(
      themePreference: state.themePreference,
      themeBackgroundPreference: value,
      themeProfilePreference: state.themeProfilePreference,
      themeSolidPrimaryPreference: state.themeSolidPrimaryPreference,
      systemBrightness: state.systemBrightness,
    );
  }

  Future<void> setThemeProfilePreference(AppThemeProfilePreference value) async {
    await _storage.writeThemeProfilePreference(value);
    state = resolveAppThemeState(
      themePreference: state.themePreference,
      themeBackgroundPreference: state.themeBackgroundPreference,
      themeProfilePreference: value,
      themeSolidPrimaryPreference: state.themeSolidPrimaryPreference,
      systemBrightness: state.systemBrightness,
    );
  }

  Future<void> setThemeSolidPrimaryPreference(
    AppThemeSolidPrimaryPreference value,
  ) async {
    await _storage.writeThemeSolidPrimaryPreference(value);
    state = resolveAppThemeState(
      themePreference: state.themePreference,
      themeBackgroundPreference: state.themeBackgroundPreference,
      themeProfilePreference: state.themeProfilePreference,
      themeSolidPrimaryPreference: value,
      systemBrightness: state.systemBrightness,
    );
  }

  Future<void> syncSystemBrightness(Brightness brightness) async {
    if (brightness == state.systemBrightness) {
      return;
    }

    state = resolveAppThemeState(
      themePreference: state.themePreference,
      themeBackgroundPreference: state.themeBackgroundPreference,
      themeProfilePreference: state.themeProfilePreference,
      themeSolidPrimaryPreference: state.themeSolidPrimaryPreference,
      systemBrightness: brightness,
    );
  }
}
