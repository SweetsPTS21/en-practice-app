import 'package:flutter/material.dart';

import 'theme_backgrounds.dart';
import 'theme_mode_prefs.dart';
import 'theme_tokens.dart';

enum AppThemeProfilePreference {
  glass,
  calm,
  contrast,
  editorial,
  pulse,
  focus,
  signal,
  solid,
  mono,
}

AppThemeProfilePreference parseThemeProfilePreference(String? value) {
  return AppThemeProfilePreference.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AppThemeProfilePreference.glass,
  );
}

@immutable
class AppThemeProfileBehavior {
  const AppThemeProfileBehavior({
    this.lockMode,
    this.lockBackground,
  });

  final AppThemePreference? lockMode;
  final AppThemeBackgroundPreference? lockBackground;
}

@immutable
class AppThemePaletteOverride {
  const AppThemePaletteOverride({
    this.primary,
    this.primaryStrong,
    this.secondary,
    this.accent,
    this.borderAccent,
    this.shadowAccent,
  });

  final Color? primary;
  final Color? primaryStrong;
  final Color? secondary;
  final Color? accent;
  final Color? borderAccent;
  final Color? shadowAccent;
}

@immutable
class AppThemeProfileDefinition {
  const AppThemeProfileDefinition({
    required this.radius,
    required this.typography,
    required this.motion,
    required this.density,
    this.palette = const AppThemePaletteOverride(),
    this.behavior = const AppThemeProfileBehavior(),
  });

  final AppRadiusTokens radius;
  final AppTypographyTokens typography;
  final AppMotionTokens motion;
  final AppDensityTokens density;
  final AppThemePaletteOverride palette;
  final AppThemeProfileBehavior behavior;
}

const _regularDensity = AppDensityTokens(
  controlHeight: 52,
  controlHeightSmall: 40,
  controlHeightLarge: 60,
  panelPadding: 20,
  compactGap: 10,
  regularGap: 16,
);

const appThemeProfiles = <AppThemeProfilePreference, AppThemeProfileDefinition>{
  AppThemeProfilePreference.glass: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 8,
      sm: 12,
      md: 16,
      lg: 22,
      xl: 28,
      xxl: 34,
      xxxl: 40,
      hero: 36,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.35,
      bodyTracking: 0,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 140),
      normal: Duration(milliseconds: 220),
      slow: Duration(milliseconds: 340),
      blurSoft: 12,
      blurStrong: 24,
      hoverLift: 4,
    ),
    density: _regularDensity,
    palette: AppThemePaletteOverride(
      accent: Color(0xFF8C7DFF),
      shadowAccent: Color(0x664C7BFF),
    ),
  ),
  AppThemeProfilePreference.calm: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 6,
      sm: 10,
      md: 14,
      lg: 18,
      xl: 24,
      xxl: 28,
      xxxl: 32,
      hero: 28,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.2,
      bodyTracking: 0.1,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 160),
      normal: Duration(milliseconds: 240),
      slow: Duration(milliseconds: 360),
      blurSoft: 8,
      blurStrong: 16,
      hoverLift: 3,
    ),
    density: _regularDensity,
    palette: AppThemePaletteOverride(
      accent: Color(0xFF53A390),
      shadowAccent: Color(0x554FA38F),
    ),
  ),
  AppThemeProfilePreference.contrast: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 4,
      sm: 6,
      md: 8,
      lg: 12,
      xl: 16,
      xxl: 20,
      xxxl: 24,
      hero: 18,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.5,
      bodyTracking: 0,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 100),
      normal: Duration(milliseconds: 160),
      slow: Duration(milliseconds: 240),
      blurSoft: 2,
      blurStrong: 6,
      hoverLift: 2,
    ),
    density: AppDensityTokens(
      controlHeight: 48,
      controlHeightSmall: 36,
      controlHeightLarge: 56,
      panelPadding: 18,
      compactGap: 8,
      regularGap: 14,
    ),
    palette: AppThemePaletteOverride(
      primary: Color(0xFF111827),
      primaryStrong: Color(0xFF000000),
      accent: Color(0xFF1F2937),
    ),
  ),
  AppThemeProfilePreference.editorial: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 6,
      sm: 10,
      md: 14,
      lg: 18,
      xl: 24,
      xxl: 28,
      xxxl: 34,
      hero: 30,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'serif',
      titleTracking: -0.8,
      bodyTracking: 0.15,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 150),
      normal: Duration(milliseconds: 240),
      slow: Duration(milliseconds: 360),
      blurSoft: 6,
      blurStrong: 14,
      hoverLift: 3,
    ),
    density: _regularDensity,
    palette: AppThemePaletteOverride(
      accent: Color(0xFFB5613B),
      shadowAccent: Color(0x55423A2C),
    ),
  ),
  AppThemeProfilePreference.pulse: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 8,
      sm: 12,
      md: 16,
      lg: 22,
      xl: 28,
      xxl: 32,
      xxxl: 36,
      hero: 32,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.45,
      bodyTracking: 0,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 120),
      normal: Duration(milliseconds: 200),
      slow: Duration(milliseconds: 300),
      blurSoft: 10,
      blurStrong: 18,
      hoverLift: 5,
    ),
    density: _regularDensity,
    palette: AppThemePaletteOverride(
      primary: Color(0xFF6D28D9),
      primaryStrong: Color(0xFF5B21B6),
      accent: Color(0xFFEC4899),
      shadowAccent: Color(0x66D946EF),
    ),
  ),
  AppThemeProfilePreference.focus: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 4,
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
      xxl: 24,
      xxxl: 28,
      hero: 24,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.3,
      bodyTracking: 0,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 90),
      normal: Duration(milliseconds: 150),
      slow: Duration(milliseconds: 220),
      blurSoft: 0,
      blurStrong: 0,
      hoverLift: 1,
    ),
    density: AppDensityTokens(
      controlHeight: 46,
      controlHeightSmall: 36,
      controlHeightLarge: 54,
      panelPadding: 16,
      compactGap: 8,
      regularGap: 14,
    ),
    palette: AppThemePaletteOverride(
      accent: Color(0xFF2563EB),
    ),
  ),
  AppThemeProfilePreference.signal: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 6,
      sm: 10,
      md: 14,
      lg: 18,
      xl: 24,
      xxl: 28,
      xxxl: 32,
      hero: 28,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.4,
      bodyTracking: 0.05,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 130),
      normal: Duration(milliseconds: 210),
      slow: Duration(milliseconds: 320),
      blurSoft: 4,
      blurStrong: 8,
      hoverLift: 2,
    ),
    density: _regularDensity,
    palette: AppThemePaletteOverride(
      primary: Color(0xFF9A3412),
      primaryStrong: Color(0xFF7C2D12),
      accent: Color(0xFFF97316),
      shadowAccent: Color(0x55F97316),
    ),
  ),
  AppThemeProfilePreference.solid: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 6,
      sm: 8,
      md: 12,
      lg: 16,
      xl: 20,
      xxl: 24,
      xxxl: 28,
      hero: 24,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'sans-serif',
      titleTracking: -0.25,
      bodyTracking: 0,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 110),
      normal: Duration(milliseconds: 180),
      slow: Duration(milliseconds: 260),
      blurSoft: 0,
      blurStrong: 0,
      hoverLift: 1,
    ),
    density: AppDensityTokens(
      controlHeight: 48,
      controlHeightSmall: 38,
      controlHeightLarge: 56,
      panelPadding: 18,
      compactGap: 10,
      regularGap: 16,
    ),
  ),
  AppThemeProfilePreference.mono: AppThemeProfileDefinition(
    radius: AppRadiusTokens(
      xs: 4,
      sm: 6,
      md: 8,
      lg: 12,
      xl: 14,
      xxl: 18,
      xxxl: 20,
      hero: 18,
    ),
    typography: AppTypographyTokens(
      fontFamily: 'sans-serif',
      fontFamilyDisplay: 'monospace',
      titleTracking: -0.2,
      bodyTracking: 0,
    ),
    motion: AppMotionTokens(
      fast: Duration(milliseconds: 90),
      normal: Duration(milliseconds: 140),
      slow: Duration(milliseconds: 220),
      blurSoft: 0,
      blurStrong: 0,
      hoverLift: 1,
    ),
    density: AppDensityTokens(
      controlHeight: 44,
      controlHeightSmall: 34,
      controlHeightLarge: 52,
      panelPadding: 16,
      compactGap: 8,
      regularGap: 12,
    ),
    palette: AppThemePaletteOverride(
      primary: Color(0xFFE5E7EB),
      primaryStrong: Color(0xFFFFFFFF),
      secondary: Color(0xFF1F2937),
      accent: Color(0xFF9CA3AF),
      borderAccent: Color(0x66D1D5DB),
      shadowAccent: Color(0x33000000),
    ),
    behavior: AppThemeProfileBehavior(
      lockMode: AppThemePreference.dark,
      lockBackground: AppThemeBackgroundPreference.midnight,
    ),
  ),
};
