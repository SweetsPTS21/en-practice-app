enum AppThemePreference { light, dark, system }

enum AppResolvedTheme { light, dark }

AppThemePreference parseThemePreference(String? value) {
  return AppThemePreference.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AppThemePreference.system,
  );
}
