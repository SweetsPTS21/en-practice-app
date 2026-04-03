import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import 'leaderboard_api.dart';
import 'leaderboard_models.dart';

final leaderboardApiProvider = Provider<LeaderboardApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return LeaderboardApi(client);
});

final leaderboardSummaryProvider = FutureProvider<LeaderboardSummaryResponse>((
  ref,
) async {
  final api = ref.watch(leaderboardApiProvider);
  return api.getSummary();
});
