import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_providers.dart';
import '../../features/results/data/completion_snapshot_api.dart';
import 'ielts_api.dart';

final ieltsCompletionSnapshotApiProvider = Provider<CompletionSnapshotApi>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return CompletionSnapshotApi(client);
});

final ieltsApiProvider = Provider<IeltsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  final completionSnapshotApi = ref.watch(ieltsCompletionSnapshotApiProvider);
  return IeltsApi(client, completionSnapshotApi);
});
