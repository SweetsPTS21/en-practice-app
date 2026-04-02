import 'package:flutter/material.dart';

enum AppThemeSolidPrimaryPreference {
  violet,
  blue,
  emerald,
  amber,
  rose,
}

AppThemeSolidPrimaryPreference parseThemeSolidPrimaryPreference(String? value) {
  return AppThemeSolidPrimaryPreference.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AppThemeSolidPrimaryPreference.violet,
  );
}

@immutable
class AppSolidPrimaryPreset {
  const AppSolidPrimaryPreset({
    required this.primary,
    required this.primaryStrong,
    required this.secondary,
    required this.accent,
  });

  final Color primary;
  final Color primaryStrong;
  final Color secondary;
  final Color accent;
}

const appSolidPrimaryPresets = <AppThemeSolidPrimaryPreference, AppSolidPrimaryPreset>{
  AppThemeSolidPrimaryPreference.violet: AppSolidPrimaryPreset(
    primary: Color(0xFF6D4AFF),
    primaryStrong: Color(0xFF5632E6),
    secondary: Color(0xFFE9E2FF),
    accent: Color(0xFF8B72FF),
  ),
  AppThemeSolidPrimaryPreference.blue: AppSolidPrimaryPreset(
    primary: Color(0xFF2563EB),
    primaryStrong: Color(0xFF1D4ED8),
    secondary: Color(0xFFDCEAFF),
    accent: Color(0xFF4F8BFF),
  ),
  AppThemeSolidPrimaryPreference.emerald: AppSolidPrimaryPreset(
    primary: Color(0xFF059669),
    primaryStrong: Color(0xFF047857),
    secondary: Color(0xFFD8F5EA),
    accent: Color(0xFF34C795),
  ),
  AppThemeSolidPrimaryPreference.amber: AppSolidPrimaryPreset(
    primary: Color(0xFFD97706),
    primaryStrong: Color(0xFFB45309),
    secondary: Color(0xFFFDEBCD),
    accent: Color(0xFFF2A93B),
  ),
  AppThemeSolidPrimaryPreference.rose: AppSolidPrimaryPreset(
    primary: Color(0xFFE11D48),
    primaryStrong: Color(0xFFBE123C),
    secondary: Color(0xFFFFE0E7),
    accent: Color(0xFFFF5C85),
  ),
};
