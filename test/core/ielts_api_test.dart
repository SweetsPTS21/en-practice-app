import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:enpractice/core/ielts/ielts_api.dart';
import 'package:enpractice/core/ielts/ielts_models.dart';
import 'package:enpractice/core/ielts/ielts_query_params.dart';
import 'package:enpractice/features/results/data/completion_snapshot_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ielts api', () {
    test('parses paged test list payload from items', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/ielts/tests': '''
          {
            "page": 0,
            "size": 10,
            "totalElements": 1,
            "totalPages": 1,
            "items": [
              {
                "testId": "test-1",
                "title": "Cambridge Reading 1",
                "skill": "READING",
                "questionCount": 40,
                "estimatedMinutes": 60,
                "sections": []
              }
            ]
          }
          ''',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final api = IeltsApi(client, CompletionSnapshotApi(client));

      final tests = await api.getTests(const IeltsTestQueryParams());

      expect(tests.items, hasLength(1));
      expect(tests.items.first.testId, 'test-1');
      expect(tests.items.first.title, 'Cambridge Reading 1');
    });

    test('parses wrapped paged test list payload from data.items', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/ielts/tests': '''
          {
            "success": true,
            "message": "OK",
            "data": {
              "page": 0,
              "size": 10,
              "totalElements": 1,
              "totalPages": 1,
              "items": [
                {
                  "id": "test-2",
                  "title": "Cambridge Reading 2",
                  "skill": "READING",
                  "timeLimitMinutes": 60,
                  "totalQuestions": 40
                }
              ]
            }
          }
          ''',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final api = IeltsApi(client, CompletionSnapshotApi(client));

      final tests = await api.getTests(const IeltsTestQueryParams());

      expect(tests.items, hasLength(1));
      expect(tests.items.first.testId, 'test-2');
      expect(tests.items.first.questionCount, 40);
    });

    test('parses session detail from wrapped data.testDetail payload', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/ielts/sessions/attempt-1': '''
          {
            "success": true,
            "message": "OK",
            "data": {
              "attemptId": "attempt-1",
              "attemptMode": "FULL",
              "scopeType": "TEST",
              "scopeId": "test-1",
              "scopeTitle": "IELTS Academic 19 Reading Test 3",
              "totalQuestions": 40,
              "estimatedMinutes": 60,
              "testDetail": {
                "id": "test-1",
                "title": "IELTS Academic 19 Reading Test 3",
                "skill": "READING",
                "timeLimitMinutes": 60,
                "sections": [
                  {
                    "id": "section-1",
                    "title": "Section 1",
                    "instructions": "Read passage 1",
                    "passages": [
                      {
                        "id": "passage-1",
                        "title": "Passage",
                        "content": "Shared context",
                        "sharedContentOnly": true,
                        "questions": []
                      },
                      {
                        "id": "passage-2",
                        "title": "Questions 1-2",
                        "content": "Answer the questions",
                        "questions": [
                          {
                            "id": "question-1",
                            "questionOrder": 1,
                            "questionType": "TRUE_FALSE_NOT_GIVEN",
                            "questionText": "Question one",
                            "options": []
                          },
                          {
                            "id": "question-2",
                            "questionOrder": 2,
                            "questionType": "PASSAGE_COMPLETION",
                            "questionText": "Question two",
                            "options": []
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          }
          ''',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final api = IeltsApi(client, CompletionSnapshotApi(client));

      final session = await api.getSession('attempt-1');

      expect(session.attemptId, 'attempt-1');
      expect(session.testId, 'test-1');
      expect(session.testTitle, 'IELTS Academic 19 Reading Test 3');
      expect(session.skill, IeltsSkill.reading);
      expect(session.sections, hasLength(1));
      expect(session.sections.first.sectionOrder, 1);
      expect(session.sections.first.instructions, 'Read passage 1');
      expect(session.sections.first.passages, hasLength(2));
      expect(session.sections.first.passages.first.passageOrder, 1);
      expect(session.sections.first.passages.first.content, 'Shared context');
      expect(session.sections.first.passages.first.sharedContentOnly, isTrue);
      expect(session.allQuestions, hasLength(2));
      expect(session.allQuestions.first.questionId, 'question-1');
    });

    test('keeps reading questions ordered by passage when questionOrder resets', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/ielts/sessions/attempt-2': '''
          {
            "success": true,
            "message": "OK",
            "data": {
              "attemptId": "attempt-2",
              "attemptMode": "FULL",
              "scopeType": "TEST",
              "testDetail": {
                "id": "test-2",
                "title": "Reading order test",
                "skill": "READING",
                "sections": [
                  {
                    "id": "section-1",
                    "title": "Section 1",
                    "passages": [
                      {
                        "id": "passage-1",
                        "title": "Questions 1-2",
                        "content": "Passage 1",
                        "questions": [
                          {
                            "id": "p1-q1",
                            "questionOrder": 1,
                            "questionType": "TRUE_FALSE_NOT_GIVEN",
                            "questionText": "P1 Q1"
                          },
                          {
                            "id": "p1-q2",
                            "questionOrder": 2,
                            "questionType": "TRUE_FALSE_NOT_GIVEN",
                            "questionText": "P1 Q2"
                          }
                        ]
                      },
                      {
                        "id": "passage-2",
                        "title": "Questions 3-4",
                        "content": "Passage 2",
                        "questions": [
                          {
                            "id": "p2-q1",
                            "questionOrder": 1,
                            "questionType": "TRUE_FALSE_NOT_GIVEN",
                            "questionText": "P2 Q1"
                          },
                          {
                            "id": "p2-q2",
                            "questionOrder": 2,
                            "questionType": "TRUE_FALSE_NOT_GIVEN",
                            "questionText": "P2 Q2"
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          }
          ''',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final api = IeltsApi(client, CompletionSnapshotApi(client));

      final session = await api.getSession('attempt-2');

      expect(
        session.sections.first.questions.map((question) => question.questionId).toList(),
        ['p1-q1', 'p1-q2', 'p2-q1', 'p2-q2'],
      );
    });

    test('parses listening session with section audio and passage questions', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/ielts/sessions/attempt-listening': '''
          {
            "success": true,
            "message": "OK",
            "data": {
              "attemptId": "attempt-listening",
              "attemptMode": "QUICK",
              "scopeType": "PASSAGE",
              "scopeId": "passage-2",
              "testDetail": {
                "id": "test-listening",
                "title": "Cambridge Listening Test",
                "skill": "LISTENING",
                "sections": [
                  {
                    "id": "section-1",
                    "sectionOrder": 1,
                    "title": "Section 1",
                    "instructions": "Questions 1-5",
                    "audioUrl": "https://cdn.example.com/section-1.mp3",
                    "passages": [
                      {
                        "id": "passage-2",
                        "passageOrder": 2,
                        "title": "Questions 1-5",
                        "content": "Listen and answer questions 1-5.",
                        "questions": [
                          {
                            "id": "question-1",
                            "questionOrder": 1,
                            "questionType": "SINGLE_CHOICE",
                            "questionText": "Question one",
                            "options": ["A", "B", "C"]
                          },
                          {
                            "id": "question-2",
                            "questionOrder": 2,
                            "questionType": "SENTENCE_COMPLETION",
                            "questionText": "Question two",
                            "options": []
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            }
          }
          ''',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final api = IeltsApi(client, CompletionSnapshotApi(client));

      final session = await api.getSession('attempt-listening');

      expect(session.skill, IeltsSkill.listening);
      expect(session.sections.first.audioUrl, 'https://cdn.example.com/section-1.mp3');
      expect(session.sections.first.passages, hasLength(1));
      expect(session.sections.first.passages.first.content, 'Listen and answer questions 1-5.');
      expect(
        session.sections.first.passages.first.questions.map((question) => question.questionId).toList(),
        ['question-1', 'question-2'],
      );
    });

    test('submit session sends userAnswer list contract', () async {
      final adapter = _RecordingAdapter(
        responses: {
          '/ielts/sessions/attempt-1/submit': '''
          {
            "success": true,
            "message": "OK",
            "data": {
              "attemptId": "attempt-1",
              "attemptMode": "QUICK",
              "scopeType": "PASSAGE",
              "testDetail": {
                "id": "test-1",
                "title": "Reading",
                "skill": "READING",
                "sections": []
              },
              "results": []
            }
          }
          ''',
        },
      );
      final client = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api'))
        ..httpClientAdapter = adapter;
      final api = IeltsApi(client, CompletionSnapshotApi(client));

      await api.submitSession(
        'attempt-1',
        const IeltsSubmitPayload(
          timeSpentSeconds: 120,
          answers: [
            IeltsSubmitAnswer(questionId: 'q1', answers: ['A']),
            IeltsSubmitAnswer(questionId: 'q2', answers: ['TRUE', 'FALSE']),
          ],
        ),
      );

      expect(adapter.requestBodies['/ielts/sessions/attempt-1/submit'], {
        'timeSpentSeconds': 120,
        'answers': [
          {
            'questionId': 'q1',
            'userAnswer': ['A'],
          },
          {
            'questionId': 'q2',
            'userAnswer': ['TRUE', 'FALSE'],
          },
        ],
      });
    });
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({required this.responses});

  final Map<String, String> responses;
  final Map<String, Object?> requestBodies = <String, Object?>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestBodies[options.path] = options.data;
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
