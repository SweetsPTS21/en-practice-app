import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale_storage.dart';

enum AppLocale {
  en('en'),
  vi('vi');

  const AppLocale(this.languageCode);

  final String languageCode;

  Locale get locale => Locale(languageCode);
}

AppLocale parseAppLocale(String? value) {
  return AppLocale.values.firstWhere(
    (item) => item.languageCode == value,
    orElse: () => AppLocale.en,
  );
}

final appLocaleControllerProvider =
    NotifierProvider<AppLocaleController, AppLocale>(AppLocaleController.new);

class AppLocaleController extends Notifier<AppLocale> {
  late final AppLocaleStorage _storage;

  @override
  AppLocale build() {
    _storage = ref.watch(appLocaleStorageProvider);
    final storedLanguage = _storage.readLanguageCode();
    if (storedLanguage != null) {
      return parseAppLocale(storedLanguage);
    }

    final deviceLanguage = PlatformDispatcher.instance.locale.languageCode;
    return switch (deviceLanguage) {
      'vi' => AppLocale.vi,
      _ => AppLocale.en,
    };
  }

  Future<void> initialize() async {}

  Future<void> setLocale(AppLocale locale) async {
    await _storage.writeLanguageCode(locale.languageCode);
    state = locale;
  }
}
