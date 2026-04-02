import 'package:flutter/material.dart';

@immutable
class AppTextTokens {
  const AppTextTokens({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.soft,
    required this.inverse,
  });

  final Color primary;
  final Color secondary;
  final Color muted;
  final Color soft;
  final Color inverse;
}

@immutable
class AppBackgroundTokens {
  const AppBackgroundTokens({
    required this.body,
    required this.canvas,
    required this.shell,
    required this.panel,
    required this.panelStrong,
    required this.frosted,
    required this.elevated,
    required this.overlay,
    required this.mobileDrawer,
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
}

@immutable
class AppBorderTokens {
  const AppBorderTokens({
    required this.strong,
    required this.subtle,
    required this.accent,
  });

  final Color strong;
  final Color subtle;
  final Color accent;
}

@immutable
class AppShadowTokens {
  const AppShadowTokens({
    required this.shell,
    required this.panel,
    required this.card,
    required this.accent,
  });

  final Color shell;
  final Color panel;
  final Color card;
  final Color accent;
}

@immutable
class AppRadiusTokens {
  const AppRadiusTokens({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.xxxl,
    required this.hero,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double hero;
}

@immutable
class AppTypographyTokens {
  const AppTypographyTokens({
    required this.fontFamily,
    required this.fontFamilyDisplay,
    required this.titleTracking,
    required this.bodyTracking,
  });

  final String? fontFamily;
  final String? fontFamilyDisplay;
  final double titleTracking;
  final double bodyTracking;
}

@immutable
class AppMotionTokens {
  const AppMotionTokens({
    required this.fast,
    required this.normal,
    required this.slow,
    required this.blurSoft,
    required this.blurStrong,
    required this.hoverLift,
  });

  final Duration fast;
  final Duration normal;
  final Duration slow;
  final double blurSoft;
  final double blurStrong;
  final double hoverLift;
}

@immutable
class AppDensityTokens {
  const AppDensityTokens({
    required this.controlHeight,
    required this.controlHeightSmall,
    required this.controlHeightLarge,
    required this.panelPadding,
    required this.compactGap,
    required this.regularGap,
  });

  final double controlHeight;
  final double controlHeightSmall;
  final double controlHeightLarge;
  final double panelPadding;
  final double compactGap;
  final double regularGap;
}

@immutable
class AppThemeTokens {
  const AppThemeTokens({
    required this.mode,
    required this.isDark,
    required this.primary,
    required this.primaryStrong,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.text,
    required this.background,
    required this.border,
    required this.shadow,
    required this.radius,
    required this.typography,
    required this.motion,
    required this.density,
    required this.profile,
  });

  final String mode;
  final bool isDark;
  final Color primary;
  final Color primaryStrong;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;
  final AppTextTokens text;
  final AppBackgroundTokens background;
  final AppBorderTokens border;
  final AppShadowTokens shadow;
  final AppRadiusTokens radius;
  final AppTypographyTokens typography;
  final AppMotionTokens motion;
  final AppDensityTokens density;
  final String profile;
}
