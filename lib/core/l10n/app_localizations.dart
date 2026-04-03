import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_locale_controller.dart';

class AppLocalizations {
  AppLocalizations(this.locale, this._translations);

  final Locale locale;
  final Map<String, dynamic> _translations;

  static const delegate = _AppLocalizationsDelegate();
  static final supportedLocales = AppLocale.values
      .map((item) => item.locale)
      .toList();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in widget tree.');
    return localizations!;
  }

  String t(String key) {
    final parts = key.split('.');
    dynamic current = _translations;

    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return key;
      }
    }

    return current is String ? current : key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final jsonString = await rootBundle.loadString(
      'lib/core/l10n/translations/${locale.languageCode}.json',
    );
    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    return AppLocalizations(locale, decoded);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsContextX on BuildContext {
  String tr(String key) => AppLocalizations.of(this).t(key);
}
