import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_providers.dart';
import '../../features/auth/auth_providers.dart';
import '../learning_journey/learning_journey_providers.dart';
import '../storage/shared_preferences_provider.dart';
import 'firebase_push_platform_adapter.dart';
import 'push_lifecycle_controller.dart';
import 'push_open_router.dart';
import 'push_permission_service.dart';
import 'push_platform_adapter.dart';
import 'push_registration_api.dart';
import 'push_token_service.dart';

final pushPlatformAdapterProvider = Provider<PushPlatformAdapter>((ref) {
  final bootstrap = ref.watch(firebaseBootstrapResultProvider);
  if (!bootstrap.isAvailable) {
    return const NoopPushPlatformAdapter();
  }
  return FirebasePushPlatformAdapter();
});

final pushPermissionServiceProvider = Provider<PushPermissionService>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final adapter = ref.watch(pushPlatformAdapterProvider);
  return PushPermissionService(preferences: preferences, adapter: adapter);
});

final pushRegistrationApiProvider = Provider<PushRegistrationApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return PushRegistrationApi(client);
});

final pushTokenServiceProvider = Provider<PushTokenService>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final adapter = ref.watch(pushPlatformAdapterProvider);
  final registrationApi = ref.watch(pushRegistrationApiProvider);
  return PushTokenService(
    preferences: preferences,
    adapter: adapter,
    registrationApi: registrationApi,
  );
});

final pushOpenRouterProvider = Provider<PushOpenRouter>((ref) {
  final learningJourneyActionService = ref.watch(
    learningJourneyActionServiceProvider,
  );
  return PushOpenRouter(
    learningJourneyActionService: learningJourneyActionService,
  );
});

final pushLifecycleControllerProvider =
    ChangeNotifierProvider<PushLifecycleController>((ref) {
      final auth = ref.watch(authControllerProvider);
      final controller = PushLifecycleController(
        adapter: ref.watch(pushPlatformAdapterProvider),
        permissionService: ref.watch(pushPermissionServiceProvider),
        tokenService: ref.watch(pushTokenServiceProvider),
        openRouter: ref.watch(pushOpenRouterProvider),
        isAuthenticated: auth.isAuthenticated,
      );
      ref.onDispose(controller.dispose);
      return controller;
    });
