import '../../../core/learning_journey/completion_snapshot_models.dart';
import 'completion_snapshot_api.dart';
import 'result_snapshot_request.dart';

class ResultJourneyRepository {
  ResultJourneyRepository(this._api);

  final CompletionSnapshotApi _api;

  Future<CompletionSnapshot> loadSnapshot(ResultSnapshotRequest request) {
    return _api.getCompletionSnapshot(request);
  }
}
