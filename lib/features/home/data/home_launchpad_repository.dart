import 'home_launchpad_models.dart';
import 'dashboard_api.dart';

class HomeLaunchpadRepository {
  HomeLaunchpadRepository(this._dashboardApi);

  final DashboardApi _dashboardApi;

  Future<ContinueLearningItem?> loadContinueLearning() async {
    return _dashboardApi.getContinueLearning();
  }

  Future<DailyLearningPlan?> loadDailyLearningPlan() async {
    return _dashboardApi.getDailyLearningPlan();
  }

  Future<List<QuickPracticeItem>> loadQuickPractice() async {
    return _dashboardApi.getQuickPractice();
  }

  Future<ProgressSnapshot?> loadProgressSnapshot() async {
    return _dashboardApi.getProgressSnapshot();
  }
}
