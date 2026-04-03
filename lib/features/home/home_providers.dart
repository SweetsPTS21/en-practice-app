import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../../core/learning_journey/learning_journey_providers.dart'
    show
        learningAnalyticsServiceProvider,
        learningJourneyActionServiceProvider,
        learningLaunchStoreProvider;

import '../../features/auth/auth_providers.dart';
import 'application/home_launchpad_controller.dart';
import 'application/home_launchpad_state.dart';
import 'data/dashboard_api.dart';
import 'data/home_launchpad_repository.dart';

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
