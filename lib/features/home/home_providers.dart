import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/learning_analytics_service.dart';
import '../../core/storage/shared_preferences_provider.dart';
import '../../features/auth/auth_providers.dart';
import '../../core/navigation/learning_launch_store.dart';
import 'application/home_launchpad_controller.dart';
import 'application/home_launchpad_state.dart';
import 'data/dashboard_api.dart';
import 'data/home_launchpad_repository.dart';

final learningLaunchStoreProvider = Provider<LearningLaunchStore>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return LearningLaunchStore(preferences);
});

final learningAnalyticsServiceProvider = Provider<LearningAnalyticsService>((ref) {
  final client = ref.watch(apiClientProvider);
  final launchStore = ref.watch(learningLaunchStoreProvider);
  return LearningAnalyticsService(
    client: client,
    launchStore: launchStore,
  );
});

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardApi(client);
});

final homeLaunchpadRepositoryProvider = Provider<HomeLaunchpadRepository>((ref) {
  final api = ref.watch(dashboardApiProvider);
  return HomeLaunchpadRepository(api);
});

final homeLaunchpadControllerProvider =
    AsyncNotifierProvider<HomeLaunchpadController, HomeLaunchpadState>(
  HomeLaunchpadController.new,
);
