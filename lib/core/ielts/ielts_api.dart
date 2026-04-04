import 'package:dio/dio.dart';

import '../../features/results/data/completion_snapshot_api.dart';
import '../../features/results/data/result_snapshot_request.dart';
import '../learning_journey/completion_snapshot_models.dart';
import '../network/api_error.dart';
import '../productive/paged_items.dart';
import 'ielts_models.dart';
import 'ielts_query_params.dart';

class IeltsApi {
  IeltsApi(this._client, this._completionSnapshotApi);

  final Dio _client;
  final CompletionSnapshotApi _completionSnapshotApi;

  Future<PagedItems<IeltsTestSummary>> getTests(
    IeltsTestQueryParams params,
  ) async {
    try {
      final response = await _client.get<Object?>(
        '/ielts/tests',
        queryParameters: params.toQueryParameters(),
      );
      final data = _unwrapData(response.data);
      if (data is Map) {
        return PagedItems<IeltsTestSummary>.fromJson(
          jsonMap(data),
          itemBuilder: IeltsTestSummary.fromJson,
        );
      }

      if (data is List) {
        final items = data
            .map((item) => IeltsTestSummary.fromJson(jsonMap(item)))
            .toList(growable: false);
        return PagedItems<IeltsTestSummary>(
          page: params.page,
          size: params.size,
          totalElements: items.length,
          totalPages: items.isEmpty ? 0 : 1,
          items: items,
        );
      }

      return PagedItems<IeltsTestSummary>(
        page: params.page,
        size: params.size,
        totalElements: 0,
        totalPages: 0,
        items: const <IeltsTestSummary>[],
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<Map<String, IeltsHighestScore>> getHighestScores(
    List<String> testIds,
  ) async {
    if (testIds.isEmpty) {
      return const <String, IeltsHighestScore>{};
    }

    try {
      final response = await _client.post<Object?>(
        '/ielts/tests/highest-scores',
        data: {'testIds': testIds},
      );
      final items = <IeltsHighestScore>[];
      final data = _unwrapData(response.data);
      if (data is List) {
        items.addAll(
          data
              .whereType<Object?>()
              .map((item) => IeltsHighestScore.fromJson(jsonMap(item))),
        );
      } else if (data is Map) {
        final map = jsonMap(data);
        final nestedItems = map['items'];
        if (nestedItems is List) {
          items.addAll(
            nestedItems
                .whereType<Object?>()
                .map((item) => IeltsHighestScore.fromJson(jsonMap(item))),
          );
        } else {
          for (final entry in map.entries) {
            if (entry.value is Map) {
              items.add(
                IeltsHighestScore.fromJson(
                  <String, dynamic>{'testId': entry.key, ...jsonMap(entry.value)},
                ),
              );
            }
          }
        }
      }

      return {
        for (final item in items)
          if (item.testId.isNotEmpty) item.testId: item,
      };
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsTestDetail> getTestDetail(String testId) async {
    try {
      final response = await _client.get<Object?>('/ielts/tests/$testId');
      return IeltsTestDetail.fromJson(jsonMap(_unwrapData(response.data)));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsPracticeOptions> getPracticeOptions(
    String testId, {
    required IeltsSkill fallbackSkill,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/ielts/tests/$testId/practice-options',
      );
      return IeltsPracticeOptions.fromJson(
        jsonMap(_unwrapData(response.data)),
        testId: testId,
        fallbackSkill: fallbackSkill,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsSessionDetail> startSession(IeltsStartSessionPayload payload) async {
    try {
      final response = await _client.post<Object?>(
        '/ielts/sessions/start',
        data: payload.toJson(),
      );
      return IeltsSessionDetail.fromJson(jsonMap(_unwrapData(response.data)));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsSessionDetail> getSession(String attemptId) async {
    try {
      final response = await _client.get<Object?>('/ielts/sessions/$attemptId');
      return IeltsSessionDetail.fromJson(jsonMap(_unwrapData(response.data)));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsAttemptDetail> submitSession(
    String attemptId,
    IeltsSubmitPayload payload,
  ) async {
    try {
      final response = await _client.post<Object?>(
        '/ielts/sessions/$attemptId/submit',
        data: payload.toJson(),
      );
      return IeltsAttemptDetail.fromJson(jsonMap(_unwrapData(response.data)));
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<List<IeltsAttemptHistoryItem>> getAttempts({
    String? status,
    String? skill,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get<Object?>(
        '/ielts/attempts',
        queryParameters: {
          if ((status ?? '').isNotEmpty) 'status': status,
          if ((skill ?? '').isNotEmpty) 'skill': skill,
          'limit': limit,
        },
      );
      final data = _unwrapData(response.data);
      return _readCollection(
        data,
        itemBuilder: (item) => IeltsAttemptHistoryItem.fromJson(jsonMap(item)),
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsAttemptDetail> getAttemptDetail(String attemptId) async {
    try {
      final response = await _client.get<Object?>('/ielts/attempts/$attemptId');
      CompletionSnapshot? snapshot;
      try {
        snapshot = await _completionSnapshotApi.getCompletionSnapshot(
          ResultSnapshotRequest(
            module: ResultSnapshotModule.ielts,
            referenceId: attemptId,
          ),
        );
      } catch (_) {
        snapshot = null;
      }
      return IeltsAttemptDetail.fromJson(
        jsonMap(_unwrapData(response.data)),
        completionSnapshot: snapshot,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<IeltsTranscript> getListeningTranscript(String attemptId) async {
    try {
      final response = await _client.get<Object?>(
        '/ielts/attempts/$attemptId/listening-transcript',
      );
      return IeltsTranscript.fromJson(
        jsonMap(_unwrapData(response.data)),
        attemptId: attemptId,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }
}

Object? _unwrapData(Object? data) {
  if (data is Map) {
    final map = jsonMap(data);
    if (map.containsKey('data')) {
      return map['data'];
    }
  }
  return data;
}

List<T> _readCollection<T>(
  Object? data, {
  required T Function(Object? item) itemBuilder,
}) {
  if (data is List) {
    return data.map(itemBuilder).toList(growable: false);
  }

  if (data is Map) {
    final items = jsonMap(data)['items'];
    if (items is List) {
      return items.map(itemBuilder).toList(growable: false);
    }
  }

  return <T>[];
}
