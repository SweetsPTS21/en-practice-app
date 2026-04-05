import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_locale_controller.dart';
import '../core/l10n/app_localizations.dart';
import '../core/push/push_providers.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_resolver.dart';
import '../features/auth/auth_providers.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    ref
        .read(appThemeControllerProvider.notifier)
        .syncSystemBrightness(PlatformDispatcher.instance.platformBrightness);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    unawaited(
      ref.read(pushLifecycleControllerProvider).refreshPermissionStatus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleControllerProvider);
    final themeState = ref.watch(appThemeControllerProvider);
    ref.watch(authControllerProvider);
    final router = ref.watch(appRouterProvider);
    final push = ref.watch(pushLifecycleControllerProvider);

    if (push.pendingRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = ref
            .read(pushLifecycleControllerProvider)
            .consumePendingRoute();
        if (route != null) {
          router.go(route);
        }
      });
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EN Practice',
      routerConfig: router,
      locale: locale.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildThemeData(themeState),
    );
  }
}
