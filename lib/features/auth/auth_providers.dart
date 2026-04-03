import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/shared_preferences_provider.dart';
import '../../core/storage/secure_store.dart';
import 'auth_controller.dart';
import 'data/auth_api.dart';
import 'data/auth_session_manager.dart';
import 'data/auth_session_storage.dart';

final authSessionStorageProvider = Provider<AuthSessionStorage>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final secureStore = ref.watch(secureStoreProvider);
  return AuthSessionStorage(preferences, secureStore);
});

final rawApiClientProvider = Provider<Dio>((ref) {
  return createPublicApiClient();
});

final authSessionManagerProvider = Provider<AuthSessionManager>((ref) {
  final storage = ref.watch(authSessionStorageProvider);
  final refreshClient = ref.watch(rawApiClientProvider);
  return AuthSessionManager(storage: storage, refreshClient: refreshClient);
});

final apiClientProvider = Provider<Dio>((ref) {
  final sessionManager = ref.watch(authSessionManagerProvider);
  return createAuthorizedApiClient(sessionManager: sessionManager);
});

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final authApi = ref.watch(authApiProvider);
  final storage = ref.watch(authSessionStorageProvider);
  final sessionManager = ref.watch(authSessionManagerProvider);

  return AuthController(
    authApi: authApi,
    storage: storage,
    sessionManager: sessionManager,
  );
});
