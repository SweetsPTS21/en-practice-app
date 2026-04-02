import 'package:flutter/material.dart';

import 'theme_backgrounds.dart';
import 'theme_mode_prefs.dart';
import 'theme_profiles.dart';
import 'theme_solid_primary.dart';
import 'theme_tokens.dart';

@immutable
class AppThemeState {
  const AppThemeState({
    required this.themePreference,
    required this.themeBackgroundPreference,
    required this.themeProfilePreference,
    required this.themeSolidPrimaryPreference,
    required this.systemBrightness,
    required this.effectiveThemePreference,
    required this.effectiveThemeBackgroundPreference,
    required this.resolvedTheme,
    required this.isDark,
    required this.themeModeLocked,
    required this.themeBackgroundLocked,
    required this.activeThemeProfile,
    required this.tokens,
  });

  final AppThemePreference themePreference;
  final AppThemeBackgroundPreference themeBackgroundPreference;
  final AppThemeProfilePreference themeProfilePreference;
  final AppThemeSolidPrimaryPreference themeSolidPrimaryPreference;
  final Brightness systemBrightness;
  final AppThemePreference effectiveThemePreference;
  final AppThemeBackgroundPreference effectiveThemeBackgroundPreference;
  final AppResolvedTheme resolvedTheme;
  final bool isDark;
  final bool themeModeLocked;
  final bool themeBackgroundLocked;
  final AppThemeProfileDefinition activeThemeProfile;
  final AppThemeTokens tokens;
}
