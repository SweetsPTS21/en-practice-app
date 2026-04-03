import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:enpractice/core/dictionary/review_api.dart';
import 'package:enpractice/core/vocabulary_test/vocabulary_test_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('api path regression', () {
    test('review api does not duplicate the /api prefix', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/records/review-counts': '{"today":1,"week":2,"month":3,"wrong":4,"all":5}',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;

      final api = ReviewApi(client);
      final counts = await api.getReviewCounts();

      expect(counts.all, 5);
      expect(
        adapter.requestedUris.single.toString(),
        'http://localhost:8080/api/records/review-counts',
      );
    });

    test('vocabulary test api uses the base /api prefix only once', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/vocabulary-tests': '[]',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;

      final api = VocabularyTestApi(client);
      final tests = await api.getTests();

      expect(tests, isEmpty);
      expect(
        adapter.requestedUris.single.toString(),
        'http://localhost:8080/api/vocabulary-tests',
      );
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({required this.responses});

  final Map<String, String> responses;
  final List<Uri> requestedUris = <Uri>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedUris.add(options.uri);

    return ResponseBody.fromString(
      responses[options.path] ?? '{}',
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
