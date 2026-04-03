import 'package:flutter/material.dart';

import 'page_palettes.dart';
import 'theme_tokens.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({required this.tokens, required this.pagePalettes});

  final AppThemeTokens tokens;
  final Map<AppPagePaletteKey, AppPagePalette> pagePalettes;

  @override
  AppThemeExtension copyWith({
    AppThemeTokens? tokens,
    Map<AppPagePaletteKey, AppPagePalette>? pagePalettes,
  }) {
    return AppThemeExtension(
      tokens: tokens ?? this.tokens,
      pagePalettes: pagePalettes ?? this.pagePalettes,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}

extension AppThemeContextX on BuildContext {
  AppThemeTokens get tokens =>
      Theme.of(this).extension<AppThemeExtension>()!.tokens;

  AppPagePalette pagePalette(AppPagePaletteKey key) {
    return Theme.of(this).extension<AppThemeExtension>()!.pagePalettes[key]!;
  }
}
