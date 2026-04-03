import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home_providers.dart';
import '../data/home_launchpad_repository.dart';
import 'home_launchpad_state.dart';

class HomeLaunchpadController extends AsyncNotifier<HomeLaunchpadState> {
  late final HomeLaunchpadRepository _repository;

  @override
  Future<HomeLaunchpadState> build() async {
    _repository = ref.read(homeLaunchpadRepositoryProvider);
    return _load();
  }

  Future<void> refreshLaunchpad() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<HomeLaunchpadState> _load() async {
    var hasRecoverableError = false;

    Future<T?> attempt<T>(Future<T?> Function() action) async {
      try {
        return await action();
      } catch (_) {
        hasRecoverableError = true;
        return null;
      }
    }

    final results = await Future.wait<dynamic>([
      attempt(_repository.loadContinueLearning),
      attempt(_repository.loadReminderBanner),
      attempt(_repository.loadDailyLearningPlan),
      attempt(_repository.loadQuickPractice),
      attempt(_repository.loadProgressSnapshot),
      attempt(_repository.loadFlagshipRetention),
    ]);

    return HomeLaunchpadState(
      continueLearning: results[0] as dynamic,
      reminderBanner: results[1] as dynamic,
      dailyPlan: results[2] as dynamic,
      quickPractice: (results[3] as List?)?.whereType<dynamic>().toList().cast() ??
          const [],
      progressSnapshot: results[4] as dynamic,
      flagshipRetention: results[5] as dynamic,
      hasRecoverableError: hasRecoverableError,
    );
  }
}
