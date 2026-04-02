import 'package:flutter/material.dart';

enum AppPagePaletteKey {
  profile,
  dashboard,
  dictionary,
  vocabularyTest,
  vocabularyCheck,
  review,
  evaluation,
  ielts,
  speaking,
  writing,
  leaderboard,
}

@immutable
class AppPagePalette {
  const AppPagePalette({
    required this.heroTop,
    required this.heroBottom,
    required this.accent,
    required this.accentSoft,
  });

  final Color heroTop;
  final Color heroBottom;
  final Color accent;
  final Color accentSoft;
}

const appPagePalettes = <AppPagePaletteKey, AppPagePalette>{
  AppPagePaletteKey.profile: AppPagePalette(
    heroTop: Color(0xFF6366F1),
    heroBottom: Color(0xFF8B5CF6),
    accent: Color(0xFF7C3AED),
    accentSoft: Color(0xFFEDE9FE),
  ),
  AppPagePaletteKey.dashboard: AppPagePalette(
    heroTop: Color(0xFF0EA5E9),
    heroBottom: Color(0xFF2563EB),
    accent: Color(0xFF2563EB),
    accentSoft: Color(0xFFDBEAFE),
  ),
  AppPagePaletteKey.dictionary: AppPagePalette(
    heroTop: Color(0xFF14B8A6),
    heroBottom: Color(0xFF0F766E),
    accent: Color(0xFF0F766E),
    accentSoft: Color(0xFFCCFBF1),
  ),
  AppPagePaletteKey.vocabularyTest: AppPagePalette(
    heroTop: Color(0xFFF59E0B),
    heroBottom: Color(0xFFD97706),
    accent: Color(0xFFD97706),
    accentSoft: Color(0xFFFEF3C7),
  ),
  AppPagePaletteKey.vocabularyCheck: AppPagePalette(
    heroTop: Color(0xFF10B981),
    heroBottom: Color(0xFF047857),
    accent: Color(0xFF047857),
    accentSoft: Color(0xFFD1FAE5),
  ),
  AppPagePaletteKey.review: AppPagePalette(
    heroTop: Color(0xFFF97316),
    heroBottom: Color(0xFFEA580C),
    accent: Color(0xFFEA580C),
    accentSoft: Color(0xFFFFEDD5),
  ),
  AppPagePaletteKey.evaluation: AppPagePalette(
    heroTop: Color(0xFFEF4444),
    heroBottom: Color(0xFFB91C1C),
    accent: Color(0xFFDC2626),
    accentSoft: Color(0xFFFEE2E2),
  ),
  AppPagePaletteKey.ielts: AppPagePalette(
    heroTop: Color(0xFF8B5CF6),
    heroBottom: Color(0xFF6D28D9),
    accent: Color(0xFF7C3AED),
    accentSoft: Color(0xFFEDE9FE),
  ),
  AppPagePaletteKey.speaking: AppPagePalette(
    heroTop: Color(0xFFEC4899),
    heroBottom: Color(0xFFBE185D),
    accent: Color(0xFFDB2777),
    accentSoft: Color(0xFFFCE7F3),
  ),
  AppPagePaletteKey.writing: AppPagePalette(
    heroTop: Color(0xFF22C55E),
    heroBottom: Color(0xFF15803D),
    accent: Color(0xFF16A34A),
    accentSoft: Color(0xFFDCFCE7),
  ),
  AppPagePaletteKey.leaderboard: AppPagePalette(
    heroTop: Color(0xFFFBBF24),
    heroBottom: Color(0xFFF59E0B),
    accent: Color(0xFFD97706),
    accentSoft: Color(0xFFFEF3C7),
  ),
};
