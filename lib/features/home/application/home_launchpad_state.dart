import '../data/home_launchpad_models.dart';
import '../../../core/retention/flagship_retention_models.dart';

class HomeLaunchpadState {
  const HomeLaunchpadState({
    required this.quickPractice,
    this.continueLearning,
    this.dailyPlan,
    this.progressSnapshot,
    this.reminderBanner,
    this.flagshipRetention,
    this.hasRecoverableError = false,
  });

  final ContinueLearningItem? continueLearning;
  final DailyLearningPlan? dailyPlan;
  final List<QuickPracticeItem> quickPractice;
  final ProgressSnapshot? progressSnapshot;
  final ReminderBanner? reminderBanner;
  final FlagshipRetention? flagshipRetention;
  final bool hasRecoverableError;
}
