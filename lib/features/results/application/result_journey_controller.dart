import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/learning_journey/completion_snapshot_models.dart';
import '../../../features/auth/auth_providers.dart';
import '../data/completion_snapshot_api.dart';
import '../data/result_journey_repository.dart';
import '../data/result_snapshot_request.dart';

final completionSnapshotApiProvider = Provider<CompletionSnapshotApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return CompletionSnapshotApi(client);
});

final resultJourneyRepositoryProvider = Provider<ResultJourneyRepository>((ref) {
  final api = ref.watch(completionSnapshotApiProvider);
  return ResultJourneyRepository(api);
});

final resultJourneyControllerProvider =
    FutureProvider.autoDispose
        .family<CompletionSnapshot, ResultSnapshotRequest>((ref, request) async {
  final repository = ref.watch(resultJourneyRepositoryProvider);
  return repository.loadSnapshot(request);
});
