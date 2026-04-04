# Flutter Mobile Phase 8 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-7-productive-skills-speaking-writing-handoff.md`.

Sau khi rà soát toàn bộ kiến trúc web hiện tại, các docs handoff mobile đang có, và mapping route/API thực tế trong source code, kết luận hợp lý nhất cho phase 8 là:

- khóa vertical IELTS end-to-end trên mobile
- bao gồm browse, quick/full launch, taking flow, result/review, transcript và history
- reuse toàn bộ retention spine, result spine, recommendation spine, push spine đã dựng ở phase 2-7

Tên ngắn gọn nên dùng:

`Phase 8 - IELTS Assessment, Quick Practice, And Review Loop`

Nếu muốn tên kỹ thuật hơn:

`Phase 8 - IELTS Test List, Practice Options, Session Engine, Result Review, And Transcript Parity`

## 1. Kết Luận Sau Khi Rà Soát Toàn Bộ Kiến Trúc

Sau khi đối chiếu `src/App.jsx`, sidebar, các API modules, các page web hiện tại và toàn bộ chuỗi docs mobile base -> phase 7, có 6 kết luận chính.

### 1.1. Web hiện có 4 lớp kiến trúc rõ ràng

#### A. App foundation

- auth/session restore
- router + guarded flows
- theme system nhiều lớp
- i18n
- axios client + refresh token

#### B. Learning journey spine

- `learningAnalytics`
- `learningAction`
- `resultJourneyNavigation`
- notification action resolver
- launch context cho session start / re-entry

#### C. Retention product layer

- Home launchpad
- recommendation
- flagship retention
- weekly report / challenge / achievements
- leaderboard / XP history
- notification center + push

#### D. Learning verticals

- vocabulary
- writing
- speaking
- custom speaking conversation
- IELTS reading/listening

Mobile roadmap hiện tại đã cover gần như toàn bộ A, B, C và 3/4 của D. Phần còn thiếu lớn, chặt và có product value cao nhất là IELTS.

### 1.2. Mapping phase mobile hiện tại đã khá đầy

- `flutter-mobile-base-handoff.md`: theme, tokens, l10n, app shell foundation
- `flutter-mobile-firebase-migration-handoff.md`: Firebase runtime và App Distribution
- `phase 2`: auth/session, home launchpad, action routing, learning analytics nền
- `phase 3`: result journey, reminder banner, notification re-entry
- `phase 4`: recommendation, flagship retention, weekly report, challenge, achievements
- `phase 5`: leaderboard, XP history, push lifecycle
- `phase 6`: dictionary, review, vocabulary check, vocabulary tests
- `phase 7`: writing, speaking, guided conversation, custom speaking

### 1.3. Những first-class surfaces còn lại sau phase 7

Đối chiếu `src/App.jsx` và `src/components/layout/AppSidebar.jsx`, các cụm lớn còn lại là:

- IELTS
- profile detail/edit ở mức full page
- AI chat realtime
- một số route legacy vocabulary như `/history`, `/review`, `/evaluation`

Trong các cụm này, IELTS là cluster lớn duy nhất vừa:

- còn thiếu gần như toàn bộ trên mobile
- đã có reference implementation web rõ
- đã có docs contract tương đối chín
- là trục học tập cốt lõi của sản phẩm

### 1.4. IELTS trên web đã là vertical trưởng thành, không còn là route đơn lẻ

Các điểm neo chính:

- `src/pages/ielts/TestListPage.jsx`
- `src/pages/ielts/TestDetailPage.jsx`
- `src/pages/ielts/TestTakingPage.jsx`
- `src/pages/ielts/TestResultPage.jsx`
- `src/api/ieltsApi.js`
- `src/components/ielts/*`
- `docs/quick-test-fe-handoff.md`
- `docs/ielts-listening-transcript-fe-handoff.md`

Web hiện đã có:

- list page + history
- test detail + practice options
- full test và quick test
- section/passage scoped session
- reading shared-context handling
- listening section audio + passage seek hint
- submit/result/review
- completion snapshot
- transcript review sau submit

### 1.5. Profile và AI chat là gap thật, nhưng không nên ưu tiên trước IELTS

Profile:

- đã được cover một phần qua recommendation, leaderboard snapshot và summary flows
- full page detail/edit là quan trọng nhưng không phá parity learning core bằng IELTS

AI chat:

- có giá trị bổ trợ
- nhưng không nằm trên xương sống daily loop bằng IELTS
- phụ thuộc nhiều hơn vào WS/stream UX riêng

### 1.6. Phase 8 nên là phase IELTS depth, không nên trộn profile và chat

Lý do:

- IELTS đủ lớn để thành một phase riêng
- cluster này có shared models và state machine riêng
- nếu trộn thêm profile hoặc AI chat, phạm vi sẽ phình và làm loãng delivery

## 2. Vì Sao Phase 8 Nên Là IELTS

Phase 8 nên ưu tiên IELTS vì 5 lý do:

1. Đây là vertical học tập cốt lõi cuối cùng chưa được migrate đầy đủ.
2. Web/backend/docs của IELTS hiện đã đủ chín để mobile bám sát.
3. IELTS tận dụng trực tiếp spine phase 2-7:
    - action resolver
    - result journey
    - recommendation
    - push/notification re-entry
    - analytics
4. Đây là module có parity value rất cao với user thi IELTS thật.
5. Nếu bỏ IELTS sang sau profile/chat, mobile sẽ vẫn thiếu một trụ learning core lớn dù đã có retention shell khá đầy.

## 3. Phase Này Là Gì

Nếu phase 7 là:

- productive skills cho writing và speaking

thì phase 8 là:

- assessment loop có timing rõ
- multiple question types
- quick/full practice
- result review có transcript và answer review

Sau phase này, mobile nên có một IELTS loop hoàn chỉnh:

1. browse test
2. mở test detail
3. chọn full / section / passage
4. làm bài
5. submit
6. xem result
7. review answer / transcript
8. reopen từ history, recommendation hoặc notification khi phù hợp

## 4. Source Of Truth Cần Bám

### 4.1. Mobile docs đã có

- `docs/mobile/flutter-mobile-base-handoff.md`
- `docs/mobile/flutter-mobile-phase-2-daily-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-4-recommendation-retention-report-handoff.md`
- `docs/mobile/flutter-mobile-phase-5-gamification-push-growth-handoff.md`
- `docs/mobile/flutter-mobile-phase-6-vocabulary-mastery-assessment-handoff.md`
- `docs/mobile/flutter-mobile-phase-7-productive-skills-speaking-writing-handoff.md`

### 4.2. Docs contract chính cho phase này

- `docs/quick-test-fe-handoff.md`
- `docs/ielts-listening-transcript-fe-handoff.md`
- `docs/result-journey-reminder-api-fe-handoff.md`
- `docs/home-launchpad-api-fe-handoff.md`
- `docs/recommendation-flagship-api-fe-handoff.md`
- `docs/notification-fe.md`

### 4.3. Mã nguồn web cần coi là reference implementation

- `src/api/ieltsApi.js`
- `src/pages/ielts/TestListPage.jsx`
- `src/pages/ielts/TestDetailPage.jsx`
- `src/pages/ielts/TestTakingPage.jsx`
- `src/pages/ielts/TestResultPage.jsx`
- `src/components/ielts/TestCard.jsx`
- `src/components/ielts/AttemptHistoryTable.jsx`
- `src/components/ielts/PassageViewer.jsx`
- `src/components/ielts/QuestionNavigator.jsx`
- `src/components/ielts/ListeningTranscriptReview.jsx`
- `src/components/ielts/AnswerReview.jsx`
- `src/components/ielts/questions/*`
- `src/utils/ielts.js`
- `src/features/learning/learningAnalytics.js`
- `src/features/learning/resultJourneyNavigation.js`

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app đã có vocabulary và productive skills thành app có IELTS assessment loop thật, usable như web.

### 5.2. Technical goal

Dựng shared contracts cho:

- test list / history
- practice options
- full vs quick session start
- scoped session payload
- timer + answers + submit
- result / answer review / transcript review
- quick launch parsing từ recommendation, quick practice, continue learning

### 5.3. UX goal

Sau phase này, user nên làm được:

1. vào IELTS và lọc test
2. xem attempt history
3. mở test detail
4. chọn full test hoặc quick section/passage
5. làm bài với question UI phù hợp
6. submit và xem result
7. review đáp án
8. với listening, xem transcript sau khi nộp

## 6. In Scope

- IELTS test list page
- highest score snapshot trên test cards
- attempt history page/section
- test detail page
- practice-options modal/sheet
- full test start
- quick section start
- quick passage start
- session resume
- test taking page thật
- timer
- answer state
- question navigator
- question renderer cho các type web đang có
- submit session
- result page
- completion snapshot integration
- answer review
- listening transcript review
- route parsing cho quick launch URLs
- recommendation / continue learning / quick practice / notification re-entry vào IELTS routes

## 7. Out Of Scope

- admin CMS cho IELTS
- tạo/sửa test trên mobile
- offline draft sync đa thiết bị
- listening transcript hiển thị trước submit
- adaptive test engine mới ngoài contract web
- analytics enum mới nếu backend chưa chốt
- AI chat, profile detail/edit full, route legacy cleanup toàn bộ

## 8. Kiến Trúc Flutter Đề Xuất

```txt
lib/
  core/
    ielts/
      ielts_api.dart
      ielts_models.dart
      ielts_query_params.dart
      ielts_session_models.dart
      ielts_result_models.dart
      ielts_launch_intent.dart
      ielts_route_parser.dart
      ielts_session_payload_builder.dart
      ielts_scoped_test_detail.dart
  features/
    ielts/
      application/
        ielts_list_controller.dart
        ielts_detail_controller.dart
        ielts_session_controller.dart
        ielts_result_controller.dart
        ielts_history_controller.dart
      presentation/
        ielts_list_page.dart
        ielts_detail_page.dart
        ielts_taking_page.dart
        ielts_result_page.dart
        widgets/
          ielts_test_card.dart
          ielts_filter_bar.dart
          ielts_attempt_history_list.dart
          ielts_practice_options_sheet.dart
          ielts_timer.dart
          ielts_section_tabs.dart
          ielts_passage_viewer.dart
          ielts_question_navigator.dart
          ielts_answer_review.dart
          ielts_listening_transcript_review.dart
          questions/
            single_choice_question.dart
            multiple_choice_question.dart
            true_false_not_given_question.dart
            form_completion_question.dart
            sentence_completion_question.dart
            summary_completion_question.dart
            matching_question.dart
            matching_headings_question.dart
            map_labeling_question.dart
            passage_completion_question.dart
            question_renderer.dart
```

Nguyên tắc:

- domain IELTS giữ riêng, không trộn vào generic learning placeholder
- question-type widgets tách theo từng loại
- result/recommendation/re-entry vẫn đi qua spine chung đã có từ phase 3-5

## 9. Route Contract Cần Hoàn Thiện

Phase 2 đã dành sẵn route semantics cho IELTS. Phase 8 cần biến chúng thành first-class flow thật:

- `/ielts`
- `/ielts/test/:testId`
- `/ielts/take/:attemptId`
- `/ielts/result/:attemptId`

Ngoài ra mobile cần support alias semantics như web đang normalize:

- `/ielts/attempts/:id` -> `/ielts/result/:id`
- `/ielts/tests/:id/resume` -> `/ielts/test/:id`
- `/ielts?mode=quick&skill=READING&testId=...&attemptMode=QUICK&scopeType=PASSAGE&scopeId=...`

## 10. API Contract Cần Dùng

### 10.0. Response wrapper chung

Các endpoint IELTS user-facing hiện đi theo wrapper chuẩn:

```json
{
    "success": true,
    "message": "OK",
    "data": {}
}
```

Mobile nên unwrap wrapper ở data layer và map sang DTO thật, không để widget đọc trực tiếp `success/message/data`.

Gợi ý:

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T data;
}
```

### 10.1. Browse và detail

- `GET /api/ielts/tests`
- `GET /api/ielts/tests/{id}`
- `POST /api/ielts/tests/highest-scores`

#### A. Test list

Response model gợi ý:

```dart
class IeltsTestListResponse {
  final List<IeltsTestSummary> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}

class IeltsTestSummary {
  final String id;
  final String title;
  final String skill;
  final String difficulty;
  final int timeLimitMinutes;
  final int totalQuestions;
  final String? description;
}
```

Response mẫu:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "items": [
            {
                "id": "test-1",
                "title": "Cambridge Reading Test 1",
                "skill": "READING",
                "difficulty": "MEDIUM",
                "timeLimitMinutes": 60,
                "totalQuestions": 40,
                "description": "Academic reading practice."
            }
        ],
        "page": 0,
        "size": 10,
        "totalElements": 1,
        "totalPages": 1
    }
}
```

#### B. Test detail

Response model gợi ý:

```dart
class IeltsTestDetail {
  final String id;
  final String title;
  final String skill;
  final String difficulty;
  final int timeLimitMinutes;
  final List<IeltsSection> sections;
}

class IeltsSection {
  final String id;
  final int sectionOrder;
  final String? title;
  final String? instructions;
  final String? audioUrl;
  final List<IeltsPassage> passages;
}

class IeltsPassage {
  final String id;
  final int passageOrder;
  final String? title;
  final String? content;
  final bool? sharedContentOnly;
  final List<IeltsQuestion> questions;
}

class IeltsQuestion {
  final String id;
  final int questionOrder;
  final String questionType;
  final String questionText;
  final dynamic options;
}
```

Rule rất quan trọng cho mobile:

- `section.instructions` và `passage.content` phải được render như markdown, không phải plain text
- nếu backend content có heading/list/emphasis/table-like markdown, mobile phải render đúng markdown semantics

### 10.1.1. Markdown rendering rules cho content

Mobile phase 8 phải coi các field sau là markdown-capable content:

- `section.instructions`
- `passage.content`
- transcript nếu backend trả theo format markdown-compatible trong tương lai

Điều này đặc biệt quan trọng cho Reading vì:

- passage gốc có thể chứa heading, xuống dòng, danh sách, nhấn mạnh
- nếu render plain text, layout và meaning có thể lệch đáng kể

Khuyến nghị:

- có một renderer markdown dùng chung cho IELTS content
- sanitize/normalize line breaks ở data layer nếu cần
- tránh tự strip markdown syntax

### 10.1.2. Quy tắc đặc biệt cho Reading section

Với bài `READING`, passage đầu tiên của một section có thể là:

- passage không có câu hỏi
- chứa đoạn văn gốc/shared context của cả section

Passage này:

- không phải quick selectable option
- nhưng phải luôn được render khi user làm các passage khác trong cùng section nếu session payload có kèm theo

Nói cách khác:

- trong test detail/practice options: không coi nó là passage để start quick riêng
- trong taking page: nếu payload có `sharedContentOnly = true` hoặc `questions = []`, luôn render như context panel phía trước passage có câu hỏi

Đây là rule bắt buộc, vì nếu mobile bỏ qua passage đầu tiên này thì user sẽ mất đoạn văn gốc khi làm passage quick còn lại trong section.

### 10.2. Pre-start và session start

- `GET /api/ielts/tests/{id}/practice-options`
- `POST /api/ielts/sessions/start`
- `GET /api/ielts/sessions/{attemptId}`

#### A. Practice options

Response model gợi ý:

```dart
class IeltsPracticeOptionsResponse {
  final String testId;
  final String title;
  final String skill;
  final String difficulty;
  final int totalQuestions;
  final int timeLimitMinutes;
  final PracticeOption fullTest;
  final List<PracticeSectionOption> sections;
}

class PracticeOption {
  final String attemptMode;
  final String scopeType;
  final String scopeId;
  final String title;
  final int questionCount;
  final int estimatedMinutes;
}

class PracticeSectionOption extends PracticeOption {
  final int sectionOrder;
  final String? audioUrl;
  final List<PracticePassageOption> passages;
}

class PracticePassageOption extends PracticeOption {
  final int sectionOrder;
  final int passageOrder;
  final String? audioUrl;
  final double? audioSeekStartRatio;
  final double? audioSeekEndRatio;
  final String? audioSeekHint;
}
```

Response mẫu:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "testId": "test-1",
        "title": "Cambridge Reading Test 1",
        "skill": "READING",
        "difficulty": "MEDIUM",
        "totalQuestions": 40,
        "timeLimitMinutes": 60,
        "fullTest": {
            "attemptMode": "FULL",
            "scopeType": "TEST",
            "scopeId": "test-1",
            "title": "Cambridge Reading Test 1",
            "questionCount": 40,
            "estimatedMinutes": 60
        },
        "sections": [
            {
                "attemptMode": "QUICK",
                "scopeType": "SECTION",
                "scopeId": "section-1",
                "sectionOrder": 1,
                "title": "Section 1",
                "questionCount": 14,
                "estimatedMinutes": 21,
                "audioUrl": null,
                "passages": [
                    {
                        "attemptMode": "QUICK",
                        "scopeType": "PASSAGE",
                        "scopeId": "passage-2",
                        "sectionOrder": 1,
                        "passageOrder": 2,
                        "title": "Passage 2",
                        "questionCount": 7,
                        "estimatedMinutes": 11,
                        "audioUrl": null,
                        "audioSeekStartRatio": null,
                        "audioSeekEndRatio": null,
                        "audioSeekHint": null
                    }
                ]
            }
        ]
    }
}
```

#### B. Start session request

Request model:

```dart
class StartIeltsSessionRequest {
  final String testId;
  final String attemptMode; // FULL | QUICK
  final String scopeType;   // TEST | SECTION | PASSAGE
  final String scopeId;
  final String? sourceRecommendationKey;
  final String? sourceSurface;
}
```

Request mẫu:

```json
{
    "testId": "test-1",
    "attemptMode": "QUICK",
    "scopeType": "PASSAGE",
    "scopeId": "passage-2",
    "sourceRecommendationKey": "rec-ielts-reading-weak-skill",
    "sourceSurface": "HOME_RECOMMENDATION"
}
```

#### C. Session payload / resume payload

Response model gợi ý:

```dart
class IeltsSessionResponse {
  final String attemptId;
  final String attemptMode;
  final String scopeType;
  final String scopeId;
  final String? scopeTitle;
  final int totalQuestions;
  final int estimatedMinutes;
  final String? sourceRecommendationKey;
  final IeltsTestDetail testDetail;
}
```

Response mẫu rút gọn:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "attemptId": "attempt-1",
        "attemptMode": "QUICK",
        "scopeType": "PASSAGE",
        "scopeId": "passage-2",
        "scopeTitle": "Passage 2",
        "totalQuestions": 7,
        "estimatedMinutes": 11,
        "sourceRecommendationKey": "rec-ielts-reading-weak-skill",
        "testDetail": {
            "id": "test-1",
            "title": "Cambridge Reading Test 1",
            "skill": "READING",
            "difficulty": "MEDIUM",
            "timeLimitMinutes": 60,
            "sections": [
                {
                    "id": "section-1",
                    "sectionOrder": 1,
                    "title": "Section 1",
                    "instructions": "## Read the passage and answer questions 1-7",
                    "audioUrl": null,
                    "passages": [
                        {
                            "id": "passage-1",
                            "passageOrder": 1,
                            "title": "Shared Reading Passage",
                            "content": "## The History of Glass\n\nGlass has been used for centuries...",
                            "sharedContentOnly": true,
                            "questions": []
                        },
                        {
                            "id": "passage-2",
                            "passageOrder": 2,
                            "title": "Questions 1-7",
                            "content": "### Questions 1-7\n\nChoose the correct heading...",
                            "sharedContentOnly": false,
                            "questions": []
                        }
                    ]
                }
            ]
        }
    }
}
```

Rule rất quan trọng:

- mobile phải tin `testDetail` từ session payload để render taking screen
- không tự refetch raw test detail rồi rebuild structure
- quick session có thể chỉ trả một section, hoặc một section với contextual passages
- với quick passage Reading, shared passage đầu tiên vẫn phải hiện nếu backend đã kèm vào payload

### 10.2.1. Listening audio rule phải khóa cứng

Với bài `LISTENING`:

- mỗi `section` có đúng một `audioUrl`
- audio thuộc `section`, không thuộc `passage`
- quick `PASSAGE` chỉ là cắt phạm vi câu hỏi, không đổi audio ownership

Điều này có nghĩa:

- UI player phải đọc từ `section.audioUrl`
- không tìm `passage.audioUrl` làm source of truth
- nếu passage quick có `audioSeekStartRatio`, dùng nó để seek trong audio của section

Đây là chỗ mobile rất dễ miss nếu map model theo passage-centric mindset.

### 10.3. Submit, result, history

- `POST /api/ielts/sessions/{attemptId}/submit`
- `GET /api/ielts/attempts`
- `GET /api/ielts/attempts/{id}`
- `GET /api/user/results/ielts/{attemptId}/completion-snapshot`

#### A. Submit request

Request model:

```dart
class SubmitIeltsSessionRequest {
  final List<IeltsAnswerSubmission> answers;
  final int timeSpentSeconds;
}

class IeltsAnswerSubmission {
  final String questionId;
  final List<String> userAnswer;
}
```

Request mẫu:

```json
{
    "answers": [
        {
            "questionId": "question-1",
            "userAnswer": ["A"]
        },
        {
            "questionId": "question-2",
            "userAnswer": ["TRUE"]
        }
    ],
    "timeSpentSeconds": 642
}
```

#### B. Attempt history response

Response model gợi ý:

```dart
class IeltsAttemptHistoryResponse {
  final List<IeltsAttemptHistoryItem> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}

class IeltsAttemptHistoryItem {
  final String attemptId;
  final String testId;
  final String testTitle;
  final String skill;
  final String attemptMode;
  final String scopeType;
  final String? scopeId;
  final String? scopeTitle;
  final double? bandScore;
  final double? accuracyPercent;
  final int totalQuestions;
  final int correctCount;
  final int timeSpentSeconds;
  final String submittedAt;
}
```

#### C. Attempt detail / result response

Response model gợi ý:

```dart
class IeltsAttemptDetailResponse {
  final String attemptId;
  final String testId;
  final String attemptMode;
  final String scopeType;
  final String? scopeId;
  final String? scopeTitle;
  final int totalQuestions;
  final int correctCount;
  final double? bandScore;
  final double? accuracyPercent;
  final int timeSpentSeconds;
  final IeltsTestDetail? testDetail;
  final List<IeltsAnswerResult> results;
}

class IeltsAnswerResult {
  final String questionId;
  final String questionText;
  final String questionType;
  final List<String> userAnswer;
  final List<String> correctAnswer;
  final bool isCorrect;
  final String? explanation;
}
```

Response mẫu rút gọn:

```json
{
    "success": true,
    "message": "OK",
    "data": {
        "attemptId": "attempt-1",
        "testId": "test-1",
        "attemptMode": "QUICK",
        "scopeType": "PASSAGE",
        "scopeId": "passage-2",
        "scopeTitle": "Passage 2",
        "totalQuestions": 7,
        "correctCount": 5,
        "bandScore": 6.0,
        "accuracyPercent": 71.4,
        "timeSpentSeconds": 642,
        "testDetail": {
            "id": "test-1",
            "title": "Cambridge Reading Test 1",
            "skill": "READING",
            "difficulty": "MEDIUM",
            "timeLimitMinutes": 60,
            "sections": []
        },
        "results": [
            {
                "questionId": "question-1",
                "questionText": "Choose the correct heading",
                "questionType": "MATCHING_HEADINGS",
                "userAnswer": ["A"],
                "correctAnswer": ["C"],
                "isCorrect": false,
                "explanation": null
            }
        ]
    }
}
```

#### D. Completion snapshot

Mobile phase 8 có thể reuse model result journey đã có từ phase 3, nhưng cần map rõ `IELTS` như một module cụ thể.

Nếu đã có shared DTO:

- không tạo DTO khác cho IELTS snapshot
- chỉ thêm adapter `GET /api/user/results/ielts/{attemptId}/completion-snapshot`

### 10.4. Listening transcript

- `GET /api/ielts/attempts/{attemptId}/listening-transcript`

Response model gợi ý:

```dart
class ListeningTranscriptResponse {
  final String testId;
  final String title;
  final String skill;
  final List<ListeningTranscriptSection> sections;
}

class ListeningTranscriptSection {
  final String id;
  final int sectionOrder;
  final String? title;
  final String? audioUrl;
  final String? transcript;
  final String? instructions;
}
```

Response mẫu:

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "testId": "test-2",
    "title": "Cambridge Listening Test 1",
    "skill": "LISTENING",
    "sections": [
      {
        "id": "section-1",
        "sectionOrder": 1,
        "title": "Section 1",
        "audioUrl": "https://cdn.example.com/listening/section-1.mp3",
        "transcript": "## Section 1\n\nGood morning. Can I see your identification, please?",
        "instructions": "Questions 1-10"
      }
    ]
  }
}

Rule:

- transcript cũng nên render markdown-capable
- transcript chỉ fetch/render ở result/review
- tuyệt đối không render transcript khi đang làm bài

## 11. Question Types Mobile Phải Sẵn Sàng Support

Theo `src/components/ielts/questions/QuestionRenderer.jsx`, mobile phase 8 nên support:

- `SINGLE_CHOICE`
- `MULTIPLE_CHOICE`
- `TRUE_FALSE_NOT_GIVEN`
- `YES_NO_NOT_GIVEN`
- `FORM_COMPLETION`
- `SENTENCE_COMPLETION`
- `SUMMARY_COMPLETION`
- `MATCHING`
- `MATCHING_HEADINGS`
- `MAP_LABELING`
- `PASSAGE_COMPLETION`

Không nên trì hoãn dispatcher. Nếu question renderer bị thiếu type, parity sẽ gãy ngay từ core session flow.

## 12. Những Quy Tắc Hành Vi Quan Trọng

### 12.1. Quick test là real flow, không phải shortcut UI

Theo `docs/quick-test-fe-handoff.md`, mobile phải coi:

- `FULL`
- `QUICK + SECTION`
- `QUICK + PASSAGE`

là ba nhánh session thật, không phải một trang full test rồi tự ẩn câu hỏi.

### 12.2. Reading shared passage không được selectable như quick option

Trong practice options:

- chỉ render `sections[].passages[]` từ backend
- không tự dựng passage options từ raw test detail

Trong session payload:

- nếu passage selected cần shared context, render nó như context-only block
- không tính vào progress câu hỏi

Phải làm rõ thêm:

- passage đầu tiên của section Reading có thể là `sharedContentOnly = true`
- passage này chính là đoạn văn gốc của section
- khi user làm `Passage 2`, `Passage 3`... trong cùng section, passage gốc này vẫn phải luôn hiển thị cùng màn làm bài nếu backend payload đã kèm theo

Nếu mobile chỉ render passage có `scopeId` hiện tại và bỏ shared passage đầu tiên, UX sẽ sai.

### 12.3. Listening passage dùng section audio

Khi `scopeType=PASSAGE`:

- audio source of truth vẫn là `section.audioUrl`
- nếu backend trả `audioSeekStartRatio`, seek đến đoạn tương ứng sau khi audio duration sẵn sàng
- `audioSeekHint` là hint, không phải hard lock

Phải khóa thêm:

- mỗi section listening có 1 audio duy nhất
- mobile không tạo player theo từng passage
- nếu user đổi passage trong cùng section thì vẫn là cùng audio section
- quick passage chỉ thay đổi question scope và seek hint, không đổi audio asset

### 12.4. Transcript chỉ hiện sau submit/review

Không hiển thị transcript ở:

- test detail
- taking page
- session payload khi đang làm

Chỉ hiển thị ở:

- result/review sau submit
- history reopen của attempt listening

Transcript và content nếu có markdown syntax phải render markdown, không flatten thành plain text.

### 12.5. Quick result và full result có primary metric khác nhau

- `FULL`: primary là `bandScore`
- `QUICK`: primary là `accuracyPercent`

Mobile UI phải giữ semantic này để khớp web.

## 13. Tích Hợp Với Spine Phase 2-7

### 13.1. Continue learning / quick practice / recommendation

Mobile phải parse và support thật các IELTS launch URLs từ:

- Home continue learning
- quick practice
- recommendation
- notification

Nếu có đủ:

- `testId`
- `attemptMode`
- `scopeType`
- `scopeId`

thì mobile nên direct-start session.

### 13.2. Learning launch context

Khi điều hướng vào:

- `/ielts/take/:attemptId`

phải nhớ launch context như các phase trước để:

- `LEARNING_STARTED`
- `LEARNING_COMPLETED`
- `RESUME_STARTED`
- `NOTIFICATION_TO_SESSION_STARTED`

không lệch semantics.

### 13.3. Result journey

`/ielts/result/:attemptId` phải reuse:

- completion snapshot section
- result action handling
- review opened / review again tracking

không dựng result CTA ngoài spine phase 3.

### 13.4. Notification và push re-entry

Push/notification có thể dẫn về:

- attempt đang dở
- result page
- quick launch route

Nên vẫn phải đi qua shared resolver, không route IELTS theo nhánh riêng.

## 14. Delivery Slices Đề Xuất

### Slice A. Browse + history foundation

- test list
- filters
- highest score
- attempt history

### Slice B. Test detail + practice options

- test detail
- full/section/passage selection
- quick launch URL parsing
- start session

### Slice C. Real taking flow

- session fetch/resume
- timer
- answer state
- section tabs
- question navigator
- question renderer family

### Slice D. Result + review

- result page
- completion snapshot
- answer review
- review again CTA
- listening transcript review

### Slice E. Retention integration

- continue learning
- recommendation
- quick practice
- notification/push reopen
- analytics alignment

## 15. Definition Of Done

Phase 8 được coi là hoàn thành khi:

1. user có thể browse IELTS tests và history trên mobile
2. user có thể mở test detail và chọn full/section/passage
3. user có thể start và resume real IELTS session
4. mobile render đúng các question types hiện có của web
5. user có thể submit session và xem result
6. quick result hiển thị accuracy, full result hiển thị band score
7. listening result có transcript review đúng thời điểm
8. continue learning / recommendation / quick practice mở được real IELTS flows
9. route alias và quick launch intent không còn rơi vào placeholder

## 16. Rủi Ro Cần Chốt Sớm

### 16.1. Question renderer parity

Đây là rủi ro lớn nhất của phase 8. Nếu chậm khóa renderer family, cả taking page sẽ bị block.

### 16.2. Scoped session payload

Mobile phải tin attempt/session payload từ backend thay vì tự suy diễn lại test structure.

### 16.3. Listening audio behavior

Seek hint, audio duration timing, và transcript gating là 3 chỗ dễ lệch semantics nhất nếu mobile tự đơn giản hóa quá tay.

## 17. Tại Sao Chưa Ưu Tiên Profile Hoặc AI Chat

### Profile

Profile full detail/edit vẫn nên làm, nhưng có thể là phase sau vì:

- summary/snapshot quan trọng đã được dùng trong các phase trước
- thiếu profile không làm gãy learning parity như thiếu IELTS

### AI chat

AI chat realtime cũng là một phase tốt sau này, nhưng nên đi sau IELTS vì:

- không phải trụ assessment core
- có WS/stream UX riêng
- không leverage trực tiếp core exam parity bằng IELTS

## 18. Kết Luận

Sau khi rà soát toàn bộ kiến trúc web và đối chiếu với toàn bộ chuỗi docs mobile đang migrate, phase 8 hợp lý nhất là:

`IELTS Assessment, Quick Practice, And Review Loop`

Đây là phase:

- bít lỗ hổng parity lớn cuối cùng của learning core
- tận dụng trực tiếp spine phase 2-7
- đủ chặt để delivery như một phase riêng
- có product value cao hơn profile/chat ở thời điểm hiện tại

Nếu cần chốt ngắn gọn thứ tự sau phase 7, nên đi:

1. IELTS
2. profile full detail/edit
3. AI chat realtime
4. legacy cleanup và polish
```
