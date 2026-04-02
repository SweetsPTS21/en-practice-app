import '../data/home_launchpad_models.dart';

class HomeLaunchpadState {
  const HomeLaunchpadState({
    required this.quickPractice,
    this.continueLearning,
    this.dailyPlan,
    this.progressSnapshot,
    this.hasRecoverableError = false,
  });

  final ContinueLearningItem? continueLearning;
  final DailyLearningPlan? dailyPlan;
  final List<QuickPracticeItem> quickPractice;
  final ProgressSnapshot? progressSnapshot;
  final bool hasRecoverableError;
}
