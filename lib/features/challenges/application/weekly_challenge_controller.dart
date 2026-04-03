import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/retention/achievement_models.dart';
import '../../../core/retention/retention_providers.dart';
import '../../../core/retention/weekly_challenge_models.dart';
import '../../../core/retention/weekly_report_models.dart';

class WeeklyChallengeScreenState {
  const WeeklyChallengeScreenState({
    required this.achievements,
    this.challenge,
    this.report,
  });

  final WeeklyChallenge? challenge;
  final List<Achievement> achievements;
  final WeeklyReport? report;
}

final weeklyChallengeScreenControllerProvider =
    FutureProvider.autoDispose<WeeklyChallengeScreenState>((ref) async {
      final challengeApi = ref.watch(weeklyChallengeApiProvider);
      final achievementApi = ref.watch(achievementApiProvider);
      final weeklyReportApi = ref.watch(weeklyReportApiProvider);

      WeeklyChallenge? challenge;
      WeeklyReport? report;
      List<Achievement> achievements = const <Achievement>[];

      try {
        challenge = await challengeApi.getCurrentWeekly();
      } catch (_) {}

      try {
        achievements = sortAchievements(await achievementApi.getAchievements());
      } catch (_) {}

      try {
        report = await weeklyReportApi.getLatest();
      } catch (_) {}

      return WeeklyChallengeScreenState(
        challenge: challenge,
        achievements: achievements,
        report: report,
      );
    });
