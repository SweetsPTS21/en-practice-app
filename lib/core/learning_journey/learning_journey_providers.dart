import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../analytics/learning_analytics_service.dart';
import '../storage/shared_preferences_provider.dart';
import '../navigation/learning_launch_store.dart';
import 'learning_journey_action_service.dart';

final learningLaunchStoreProvider = Provider<LearningLaunchStore>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return LearningLaunchStore(preferences);
});

final learningAnalyticsServiceProvider = Provider<LearningAnalyticsService>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  final launchStore = ref.watch(learningLaunchStoreProvider);
  return LearningAnalyticsService(client: client, launchStore: launchStore);
});

final learningJourneyActionServiceProvider =
    Provider<LearningJourneyActionService>((ref) {
      final analyticsService = ref.watch(learningAnalyticsServiceProvider);
      final launchStore = ref.watch(learningLaunchStoreProvider);
      return LearningJourneyActionService(
        analyticsService: analyticsService,
        launchStore: launchStore,
      );
    });
