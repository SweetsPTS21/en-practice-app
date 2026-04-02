import 'package:flutter/material.dart';

import 'app_theme_state.dart';
import 'page_palettes.dart';
import 'theme_backgrounds.dart';
import 'theme_extensions.dart';
import 'theme_mode_prefs.dart';
import 'theme_profiles.dart';
import 'theme_solid_primary.dart';
import 'theme_tokens.dart';

AppThemeState resolveAppThemeState({
  required AppThemePreference themePreference,
  required AppThemeBackgroundPreference themeBackgroundPreference,
  required AppThemeProfilePreference themeProfilePreference,
  required AppThemeSolidPrimaryPreference themeSolidPrimaryPreference,
  required Brightness systemBrightness,
}) {
  final profile = appThemeProfiles[themeProfilePreference]!;
  final effectiveThemePreference = profile.behavior.lockMode ?? themePreference;
  final effectiveThemeBackgroundPreference =
      profile.behavior.lockBackground ?? themeBackgroundPreference;
  final resolvedTheme = switch (effectiveThemePreference) {
    AppThemePreference.light => AppResolvedTheme.light,
    AppThemePreference.dark => AppResolvedTheme.dark,
    AppThemePreference.system => systemBrightness == Brightness.dark
        ? AppResolvedTheme.dark
        : AppResolvedTheme.light,
  };
  final isDark = resolvedTheme == AppResolvedTheme.dark;
  final surfaces =
      appThemeBackgroundPresets[effectiveThemeBackgroundPreference]!.resolve(isDark);

  var primary = isDark ? const Color(0xFF7AB8FF) : const Color(0xFF2563EB);
  var primaryStrong = isDark ? const Color(0xFFB9D6FF) : const Color(0xFF1D4ED8);
  var secondary = isDark ? const Color(0xFF12263C) : const Color(0xFFDCEAFE);
  var accent = isDark ? const Color(0xFF8B9EFF) : const Color(0xFF4F46E5);
  var borderAccent = accent.withValues(alpha: isDark ? 0.52 : 0.28);
  var shadowAccent = accent.withValues(alpha: isDark ? 0.24 : 0.14);

  final palette = profile.palette;
  primary = palette.primary ?? primary;
  primaryStrong = palette.primaryStrong ?? primaryStrong;
  secondary = palette.secondary ?? secondary;
  accent = palette.accent ?? accent;
  borderAccent = palette.borderAccent ?? borderAccent;
  shadowAccent = palette.shadowAccent ?? shadowAccent;

  if (themeProfilePreference == AppThemeProfilePreference.solid) {
    final solid = appSolidPrimaryPresets[themeSolidPrimaryPreference]!;
    primary = solid.primary;
    primaryStrong = solid.primaryStrong;
    secondary = solid.secondary;
    accent = solid.accent;
    borderAccent = accent.withValues(alpha: isDark ? 0.56 : 0.30);
    shadowAccent = accent.withValues(alpha: isDark ? 0.22 : 0.14);
  }

  final text = AppTextTokens(
    primary: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    secondary: isDark ? const Color(0xFFD4DDEB) : const Color(0xFF334155),
    muted: isDark ? const Color(0xFF9FB0C8) : const Color(0xFF64748B),
    soft: isDark ? const Color(0xFF8194AE) : const Color(0xFF94A3B8),
    inverse: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF),
  );

  final tokens = AppThemeTokens(
    mode: resolvedTheme.name,
    isDark: isDark,
    primary: primary,
    primaryStrong: primaryStrong,
    secondary: secondary,
    accent: accent,
    success: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
    warning: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
    danger: isDark ? const Color(0xFFFB7185) : const Color(0xFFDC2626),
    text: text,
    background: AppBackgroundTokens(
      body: surfaces.body,
      canvas: surfaces.canvas,
      shell: surfaces.shell,
      panel: surfaces.panel,
      panelStrong: surfaces.panelStrong,
      frosted: surfaces.frosted,
      elevated: surfaces.elevated,
      overlay: surfaces.overlay,
      mobileDrawer: surfaces.mobileDrawer,
    ),
    border: AppBorderTokens(
      strong: isDark ? const Color(0xFF31435B) : const Color(0xFFD4DEEB),
      subtle: isDark ? const Color(0xFF223147) : const Color(0xFFE6EDF5),
      accent: borderAccent,
    ),
    shadow: AppShadowTokens(
      shell: Colors.black.withValues(alpha: isDark ? 0.24 : 0.05),
      panel: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
      card: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
      accent: shadowAccent,
    ),
    radius: profile.radius,
    typography: profile.typography,
    motion: profile.motion,
    density: profile.density,
    profile: themeProfilePreference.name,
  );

  return AppThemeState(
    themePreference: themePreference,
    themeBackgroundPreference: themeBackgroundPreference,
    themeProfilePreference: themeProfilePreference,
    themeSolidPrimaryPreference: themeSolidPrimaryPreference,
    systemBrightness: systemBrightness,
    effectiveThemePreference: effectiveThemePreference,
    effectiveThemeBackgroundPreference: effectiveThemeBackgroundPreference,
    resolvedTheme: resolvedTheme,
    isDark: isDark,
    themeModeLocked: profile.behavior.lockMode != null,
    themeBackgroundLocked: profile.behavior.lockBackground != null,
    activeThemeProfile: profile,
    tokens: tokens,
  );
}

ThemeData buildThemeData(AppThemeState state) {
  final tokens = state.tokens;
  final base = ThemeData(
    useMaterial3: true,
    brightness: state.isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tokens.primary,
      brightness: state.isDark ? Brightness.dark : Brightness.light,
      primary: tokens.primary,
      secondary: tokens.accent,
      error: tokens.danger,
      surface: tokens.background.panel,
    ),
    scaffoldBackgroundColor: Colors.transparent,
  );

  final textTheme = base.textTheme.copyWith(
    displayLarge: base.textTheme.displayLarge?.copyWith(
      color: tokens.text.primary,
      fontFamily: tokens.typography.fontFamilyDisplay,
      letterSpacing: tokens.typography.titleTracking,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: base.textTheme.displayMedium?.copyWith(
      color: tokens.text.primary,
      fontFamily: tokens.typography.fontFamilyDisplay,
      letterSpacing: tokens.typography.titleTracking,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      color: tokens.text.primary,
      fontFamily: tokens.typography.fontFamilyDisplay,
      letterSpacing: tokens.typography.titleTracking,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      color: tokens.text.primary,
      fontFamily: tokens.typography.fontFamilyDisplay,
      letterSpacing: tokens.typography.titleTracking,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      color: tokens.text.primary,
      fontFamily: tokens.typography.fontFamily,
      letterSpacing: tokens.typography.titleTracking,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      color: tokens.text.primary,
      fontFamily: tokens.typography.fontFamily,
      letterSpacing: tokens.typography.bodyTracking,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      color: tokens.text.secondary,
      fontFamily: tokens.typography.fontFamily,
      letterSpacing: tokens.typography.bodyTracking,
    ),
    bodySmall: base.textTheme.bodySmall?.copyWith(
      color: tokens.text.muted,
      fontFamily: tokens.typography.fontFamily,
      letterSpacing: tokens.typography.bodyTracking,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      fontFamily: tokens.typography.fontFamily,
      letterSpacing: 0.2,
      fontWeight: FontWeight.w600,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: tokens.text.primary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: tokens.background.panel,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        side: BorderSide(color: tokens.border.subtle),
      ),
    ),
    dividerColor: tokens.border.subtle,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.background.panelStrong,
      hintStyle: textTheme.bodyMedium?.copyWith(color: tokens.text.soft),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: (tokens.density.controlHeight - 20) / 2,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        borderSide: BorderSide(color: tokens.border.subtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        borderSide: BorderSide(color: tokens.border.accent, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: tokens.secondary,
      selectedColor: tokens.primary.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        side: BorderSide(color: tokens.border.subtle),
      ),
      labelStyle: textTheme.labelMedium?.copyWith(color: tokens.text.primary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tokens.primary,
        foregroundColor: tokens.text.inverse,
        minimumSize: Size.fromHeight(tokens.density.controlHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.lg),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tokens.text.primary,
        minimumSize: Size.fromHeight(tokens.density.controlHeight),
        side: BorderSide(color: tokens.border.strong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.lg),
        ),
      ),
    ),
    extensions: [
      AppThemeExtension(
        tokens: tokens,
        pagePalettes: appPagePalettes,
      ),
    ],
  );
}
