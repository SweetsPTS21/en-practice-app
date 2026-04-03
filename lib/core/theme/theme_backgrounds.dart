import 'package:flutter/material.dart';

enum AppThemeBackgroundPreference {
  balanced,
  sage,
  ocean,
  dawn,
  amethyst,
  blossom,
  petal,
  midnight,
  ember,
  canopy,
}

AppThemeBackgroundPreference parseThemeBackgroundPreference(String? value) {
  return AppThemeBackgroundPreference.values.firstWhere(
    (item) => item.name == value,
    orElse: () => AppThemeBackgroundPreference.balanced,
  );
}

@immutable
class AppBackgroundSurfaces {
  const AppBackgroundSurfaces({
    required this.body,
    required this.canvas,
    required this.shell,
    required this.panel,
    required this.panelStrong,
    required this.frosted,
    required this.elevated,
    required this.overlay,
    required this.mobileDrawer,
    required this.bodyAccent,
  });

  final Color body;
  final Color canvas;
  final Color shell;
  final Color panel;
  final Color panelStrong;
  final Color frosted;
  final Color elevated;
  final Color overlay;
  final Color mobileDrawer;
  final Color bodyAccent;
}

@immutable
class AppBackgroundPreset {
  const AppBackgroundPreset({required this.light, required this.dark});

  final AppBackgroundSurfaces light;
  final AppBackgroundSurfaces dark;

  AppBackgroundSurfaces resolve(bool isDark) => isDark ? dark : light;
}

const appThemeBackgroundPresets =
    <AppThemeBackgroundPreference, AppBackgroundPreset>{
      AppThemeBackgroundPreference.balanced: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFF6F8FC),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFF2F4F8),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFF7FAFF),
          frosted: Color(0xEFFFFFFF),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A0F172A),
          mobileDrawer: Color(0xFFF8FAFC),
          bodyAccent: Color(0xFFDDE7FF),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF07111F),
          canvas: Color(0xFF0B1526),
          shell: Color(0xFF101C30),
          panel: Color(0xFF122034),
          panelStrong: Color(0xFF17283E),
          frosted: Color(0xD9112033),
          elevated: Color(0xFF16263C),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF0E1A2A),
          bodyAccent: Color(0xFF193055),
        ),
      ),
      AppThemeBackgroundPreference.sage: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFF4FAF5),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFEEF7F0),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFF2FBF5),
          frosted: Color(0xEAF7FFF1),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A0A1711),
          mobileDrawer: Color(0xFFF7FCF8),
          bodyAccent: Color(0xFFD6ECD8),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF07130F),
          canvas: Color(0xFF0B1913),
          shell: Color(0xFF122119),
          panel: Color(0xFF14261D),
          panelStrong: Color(0xFF193127),
          frosted: Color(0xD9152A20),
          elevated: Color(0xFF1B3027),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF112018),
          bodyAccent: Color(0xFF203B2F),
        ),
      ),
      AppThemeBackgroundPreference.ocean: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFF2F9FF),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFEAF5FF),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFF0F8FF),
          frosted: Color(0xEAF3FAFF),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A061523),
          mobileDrawer: Color(0xFFF5FAFF),
          bodyAccent: Color(0xFFD2E8FF),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF05121E),
          canvas: Color(0xFF081A29),
          shell: Color(0xFF0D2235),
          panel: Color(0xFF10273C),
          panelStrong: Color(0xFF14314A),
          frosted: Color(0xD9112840),
          elevated: Color(0xFF16334F),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF0C2032),
          bodyAccent: Color(0xFF173B5E),
        ),
      ),
      AppThemeBackgroundPreference.dawn: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFFFF7F1),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFFFF0E5),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFFFF7F0),
          frosted: Color(0xEAFFF8F1),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A24140A),
          mobileDrawer: Color(0xFFFFFAF6),
          bodyAccent: Color(0xFFFFDEC7),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF1B0F09),
          canvas: Color(0xFF24140C),
          shell: Color(0xFF301C11),
          panel: Color(0xFF352015),
          panelStrong: Color(0xFF42281A),
          frosted: Color(0xD93B2417),
          elevated: Color(0xFF472B1C),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF2C1A10),
          bodyAccent: Color(0xFF5A3420),
        ),
      ),
      AppThemeBackgroundPreference.amethyst: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFF8F5FF),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFF2ECFF),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFF7F2FF),
          frosted: Color(0xEAF7F2FF),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A1A122E),
          mobileDrawer: Color(0xFFFBF8FF),
          bodyAccent: Color(0xFFE3D7FF),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF120C21),
          canvas: Color(0xFF17102A),
          shell: Color(0xFF22163A),
          panel: Color(0xFF271C44),
          panelStrong: Color(0xFF302356),
          frosted: Color(0xD9291E4A),
          elevated: Color(0xFF34275E),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF1D1434),
          bodyAccent: Color(0xFF453373),
        ),
      ),
      AppThemeBackgroundPreference.blossom: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFFFF5F9),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFFFEEF5),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFFFF3F8),
          frosted: Color(0xEAFFF5F8),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A25101D),
          mobileDrawer: Color(0xFFFFF9FB),
          bodyAccent: Color(0xFFFFD7E7),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF1A0B14),
          canvas: Color(0xFF220F1A),
          shell: Color(0xFF301525),
          panel: Color(0xFF38182B),
          panelStrong: Color(0xFF431D34),
          frosted: Color(0xD93B1A2D),
          elevated: Color(0xFF492136),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF2A1221),
          bodyAccent: Color(0xFF592540),
        ),
      ),
      AppThemeBackgroundPreference.petal: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFFFFBF8),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFFFF4EE),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFFFF8F3),
          frosted: Color(0xEAFFF9F5),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A23150D),
          mobileDrawer: Color(0xFFFFFCFA),
          bodyAccent: Color(0xFFFFE2D4),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF1A0F0A),
          canvas: Color(0xFF24150E),
          shell: Color(0xFF311C13),
          panel: Color(0xFF372017),
          panelStrong: Color(0xFF43271B),
          frosted: Color(0xD93C2418),
          elevated: Color(0xFF492B1D),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF2B1A11),
          bodyAccent: Color(0xFF593320),
        ),
      ),
      AppThemeBackgroundPreference.midnight: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFF1F4FB),
          canvas: Color(0xFFFDFEFF),
          shell: Color(0xFFE9EEF8),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFF4F7FD),
          frosted: Color(0xEAF8FAFF),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A07101E),
          mobileDrawer: Color(0xFFF7F9FD),
          bodyAccent: Color(0xFFD7E2F8),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF040812),
          canvas: Color(0xFF08101B),
          shell: Color(0xFF0C1524),
          panel: Color(0xFF101B2C),
          panelStrong: Color(0xFF152239),
          frosted: Color(0xD9101D31),
          elevated: Color(0xFF182641),
          overlay: Color(0xCC000000),
          mobileDrawer: Color(0xFF0B1625),
          bodyAccent: Color(0xFF1B3156),
        ),
      ),
      AppThemeBackgroundPreference.ember: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFFFF6F2),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFFFEFE8),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFFFF5EF),
          frosted: Color(0xEAFFF7F1),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A281209),
          mobileDrawer: Color(0xFFFFFBF8),
          bodyAccent: Color(0xFFFFDDCF),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF180B08),
          canvas: Color(0xFF220F0B),
          shell: Color(0xFF30150F),
          panel: Color(0xFF381912),
          panelStrong: Color(0xFF451E15),
          frosted: Color(0xD93C1C14),
          elevated: Color(0xFF4A2117),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF2A120D),
          bodyAccent: Color(0xFF572519),
        ),
      ),
      AppThemeBackgroundPreference.canopy: AppBackgroundPreset(
        light: AppBackgroundSurfaces(
          body: Color(0xFFF3FAF4),
          canvas: Color(0xFFFFFFFF),
          shell: Color(0xFFEAF6EC),
          panel: Color(0xFFFFFFFF),
          panelStrong: Color(0xFFF1FAF3),
          frosted: Color(0xEAF4FBF5),
          elevated: Color(0xFFFFFFFF),
          overlay: Color(0x8A0C170F),
          mobileDrawer: Color(0xFFF7FCF8),
          bodyAccent: Color(0xFFD3EAD8),
        ),
        dark: AppBackgroundSurfaces(
          body: Color(0xFF07110A),
          canvas: Color(0xFF0B180E),
          shell: Color(0xFF112115),
          panel: Color(0xFF14271A),
          panelStrong: Color(0xFF193122),
          frosted: Color(0xD9142A1B),
          elevated: Color(0xFF1B3425),
          overlay: Color(0xA6000000),
          mobileDrawer: Color(0xFF112017),
          bodyAccent: Color(0xFF22402C),
        ),
      ),
    };
