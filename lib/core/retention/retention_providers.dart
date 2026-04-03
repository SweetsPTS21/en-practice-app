import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'achievement_api.dart';
import 'flagship_retention_api.dart';
import 'weekly_challenge_api.dart';
import 'weekly_report_api.dart';

final flagshipRetentionApiProvider = Provider<FlagshipRetentionApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return FlagshipRetentionApi(client);
});

final weeklyReportApiProvider = Provider<WeeklyReportApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return WeeklyReportApi(client);
});

final weeklyChallengeApiProvider = Provider<WeeklyChallengeApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return WeeklyChallengeApi(client);
});

final achievementApiProvider = Provider<AchievementApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AchievementApi(client);
});
