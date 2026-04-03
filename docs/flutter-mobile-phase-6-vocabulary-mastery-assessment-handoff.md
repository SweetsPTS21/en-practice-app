# Flutter Mobile Phase 6 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-5-gamification-push-growth-handoff.md`.

Nếu phase 3-5 đã khóa được:

- result journey và notification re-entry
- recommendation và retention surfaces
- leaderboard, XP history và push re-engagement

thì phase 6 là lớp giúp mobile đi từ `app đã có retention spine` sang `app có vertical vocabulary hoàn chỉnh và usable như web`.

Trọng tâm của phase này là:

- dictionary thật thay cho placeholder
- vocabulary review flow thật thay cho session placeholder
- AI-generated vocabulary tests
- vocabulary check / word validation surface
- vocabulary history và attempt history

## 1. Kết Luận Kiến Trúc Sau Khi Đối Chiếu Web Và Mobile Hiện Tại

Sau khi rà soát docs, web FE, backend contract và mobile code hiện tại, có 7 kết luận quan trọng.

### 1.1. Mobile đã có retention spine đủ mạnh để nhận thêm một learning vertical thật

Sau phase 3-5, mobile hiện đã có:

- app shell ổn định
- launch context và result journey dùng chung
- recommendation routing
- notification/push-driven re-entry
- leaderboard / XP feedback layer

Điều này có nghĩa phase 6 không cần dựng hạ tầng mới. Nó nên tận dụng spine đã có để đưa một vertical học tập thật vào app.

### 1.2. Vertical vocabulary trên web đã trưởng thành hơn hẳn trạng thái mobile hiện tại

Các điểm bám chính bên web:

- `src/pages/dictionary/DictionaryPage.jsx`
- `src/pages/dictionary/DictionaryReviewPage.jsx`
- `src/pages/VocabularyCheck.jsx`
- `src/pages/VocabularyTest.jsx`
- `src/pages/History.jsx`
- `src/pages/Review.jsx`
- `docs/vocabulary-test-fe-handoff.md`
- `docs/backend-api-spec.md`

Kết luận:

- vocabulary không còn là idea
- đây đã là một cụm feature tương đối hoàn chỉnh trên web
- mobile hiện đang thiếu gần như toàn bộ cụm này

### 1.3. Mobile hiện còn hở lớn nhất ở đúng cụm vocabulary foundation

Các khoảng trống trong mobile hiện tại:

- `lib/features/dictionary/dictionary_page.dart` vẫn là `FeatureLandingPage`
- `/dictionary/review` vẫn đi vào `LearningSessionPlaceholderPage`
- chưa có route thật cho vocabulary test list / preview / attempt / history
- chưa có vocabulary check screen
- `app_route_contract.dart` chưa support các route vocabulary mới của web

Kết luận:

- nếu muốn mobile tiến gần product parity với web, vocabulary là lát cắt có ROI cao nhất ngay sau phase 5

### 1.4. Backend contract cho review và vocabulary tests đã đủ rõ để mobile triển khai

Các contract đã có tài liệu rõ:

- review words / counts / review sessions:
  - `GET /api/records/review-words`
  - `GET /api/records/review-counts`
  - `POST /api/reviews`
  - `GET /api/reviews/last`
- AI-generated vocabulary tests:
  - `POST /api/vocabulary-tests/generate`
  - `GET /api/vocabulary-tests`
  - `GET /api/vocabulary-tests/{id}`
  - `POST /api/vocabulary-tests/{id}/start`
  - `POST /api/vocabulary-tests/attempts/{attemptId}/submit`
  - `GET /api/vocabulary-tests/attempts`
  - `GET /api/vocabulary-tests/attempts/{attemptId}`

Điểm này quan trọng vì phase 6 có thể là phase delivery thật, không chỉ là design spike.

### 1.5. Vocabulary check đã có UI reference mạnh trên web nhưng contract API chưa được đóng gói thành một handoff riêng

`src/pages/VocabularyCheck.jsx` cho thấy web đã có flow:

- validate English word
- nhập nghĩa tiếng Việt
- check correctness
- xem alternatives / explanation
- save vào dictionary

Nhưng khác với vocabulary tests, chưa có một FE handoff riêng gói contract API cho mobile.

Kết luận:

- vocabulary check nên nằm trong phase 6
- nhưng cần xem là sub-slice có mức độ xác nhận contract thấp hơn vocabulary test và review

### 1.6. Không nên chọn IELTS quick test hoặc speaking/history parity làm phase 6

Web cũng đã có quick-test và nhiều màn speaking/writing/history hoàn chỉnh hơn mobile.

Tuy nhiên nếu lấy các phần đó cho phase 6 thì phạm vi sẽ quá rộng:

- nhiều module khác nhau
- nhiều contract khác nhau
- khó reuse UI state và shared domain models

Trong khi vocabulary là một cluster chặt hơn:

- dictionary
- review
- word check
- AI-generated test
- history

### 1.7. Phase 6 hợp lý nhất là một phase vocabulary depth, không phải phase parity tổng quát

Tên ngắn gọn nên dùng:

`Phase 6 - Vocabulary Mastery, Dictionary, And AI Assessment`

Nếu muốn tên kỹ thuật hơn:

`Phase 6 - Dictionary, Review Sessions, Vocabulary Check, And AI-Generated Test Loop`

## 2. Phase Này Là Gì

Nếu phase 5 là:

- app tạo động lực quay lại bằng leaderboard và push

thì phase 6 là:

- app cho user một vertical vocabulary thật để học, ôn, kiểm tra và xem lại lịch sử trên mobile

Sau phase này, mobile không chỉ có entry point tới vocabulary nữa, mà có một loop hoàn chỉnh:

1. tra và lưu từ
2. review từ đến hạn
3. check nhanh hiểu biết về một từ
4. generate bài test cá nhân hóa bằng AI
5. làm bài, xem kết quả, xem lịch sử attempt

## 3. Source Of Truth Cần Bám

### 3.1. Mobile docs đã có

- `docs/flutter-mobile-base-handoff.md`
- `docs/flutter-mobile-phase-2-daily-loop-handoff.md`
- `docs/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`
- `docs/flutter-mobile-phase-4-recommendation-retention-report-handoff.md`
- `docs/flutter-mobile-phase-5-gamification-push-growth-handoff.md`

### 3.2. Docs contract chính cho phase này

- `../en-practice/docs/vocabulary-test-fe-handoff.md`
- `../en-practice/docs/backend-api-spec.md`
- `../en-practice/docs/project-summary-and-roadmap.md`

### 3.3. Mã nguồn web cần coi là reference implementation

- `../en-practice/src/pages/dictionary/DictionaryPage.jsx`
- `../en-practice/src/pages/dictionary/DictionaryReviewPage.jsx`
- `../en-practice/src/pages/VocabularyCheck.jsx`
- `../en-practice/src/pages/VocabularyTest.jsx`
- `../en-practice/src/pages/History.jsx`
- `../en-practice/src/pages/Review.jsx`
- `../en-practice/src/components/layout/AppSidebar.jsx`

### 3.4. Mã nguồn mobile cần coi là điểm neo hiện tại

- `lib/app/router/app_router.dart`
- `lib/core/navigation/app_route_contract.dart`
- `lib/features/dictionary/dictionary_page.dart`
- `lib/features/learning/learning_session_placeholder_page.dart`
- `lib/features/results/presentation/result_journey_page.dart`
- `lib/core/navigation/learning_action_resolver.dart`
- `lib/core/analytics/learning_analytics_service.dart`

## 4. Vì Sao Phase Này Phải Đi Sau Phase 5

Phase 6 phụ thuộc trực tiếp vào những gì phase trước đã dựng:

- review completion nên reuse result journey từ phase 3
- vocabulary test result nên reuse completion snapshot / post-result actions
- recommendation slot từ phase 4 có thể đẩy user vào vocabulary review hoặc vocab test
- leaderboard / XP history từ phase 5 giúp reward vocab review và test attempts có ý nghĩa hơn
- push / notification re-entry có thể đưa user quay lại `/dictionary/review` hoặc `/vocabulary-tests`

Nếu làm phase này sớm hơn:

- review và test result sẽ dễ bị dựng flow riêng
- notification / recommendation route sẽ phải vá lại sau
- vertical vocabulary sẽ không nối được vào hệ thống retention đã có

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app có vocabulary entry point mang tính giới thiệu thành app có vocabulary loop hoàn chỉnh và có thể dùng hằng ngày.

### 5.2. Technical goal

Dựng shared contracts cho:

- dictionary list / detail / stats / favorite / add word
- due review queue / review counts / review session submit
- vocabulary check state
- AI-generated vocabulary test list / detail / start / submit / history
- alias routing từ route web cũ sang route mobile mới

### 5.3. UX goal

Sau phase này, user nên làm được luồng sau:

1. mở Dictionary và tìm từ / xem từ đã lưu
2. mở một từ để xem chi tiết và lưu favorite
3. vào review session thật và submit session
4. xem result / recap review session
5. mở vocabulary check để tự kiểm tra một từ
6. generate một vocabulary test cá nhân hóa
7. làm bài, submit, xem kết quả và xem lại lịch sử attempt

## 6. In Scope

- dictionary page thật với search, filter, stats, saved words
- word detail page hoặc sheet riêng cho mobile
- add word / favorite toggle nếu backend hiện đã hỗ trợ trong app stack
- review queue entry từ dictionary và home quick practice
- real review session flow thay cho placeholder
- review session submit và result bridge
- vocabulary check page
- vocabulary test generate flow
- vocabulary test preview page
- vocabulary test attempt page
- vocabulary test result page
- vocabulary test attempt history page
- route alias / navigation normalization cho vocabulary routes mới
- recommendation / notification / push re-entry nối vào vocabulary routes khi phù hợp

## 7. Out Of Scope

- public vocabulary sharing giữa user với nhau
- collaborative dictionary / social comments
- advanced spaced repetition tuning UI
- offline-first dictionary sync
- voice conversation / speaking parity
- IELTS quick test
- writing / speaking / custom-speaking history parity
- analytics enum mới nếu backend chưa chốt cho vocabulary check

## 8. Kiến Trúc Flutter Đề Xuất Cho Phase Này

```txt
lib/
  core/
    dictionary/
      dictionary_api.dart
      dictionary_models.dart
      dictionary_query_params.dart
      review_api.dart
      review_models.dart
    vocabulary_check/
      vocabulary_check_service.dart
      vocabulary_check_models.dart
    vocabulary_test/
      vocabulary_test_api.dart
      vocabulary_test_models.dart
      vocabulary_test_query_params.dart
  features/
    dictionary/
      application/
        dictionary_controller.dart
        dictionary_review_controller.dart
      presentation/
        dictionary_page.dart
        dictionary_word_detail_page.dart
        dictionary_review_page.dart
        widgets/
          dictionary_stats_card.dart
          dictionary_search_bar.dart
          dictionary_word_tile.dart
          review_flashcard.dart
          review_progress_bar.dart
    vocabulary_check/
      application/
        vocabulary_check_controller.dart
      presentation/
        vocabulary_check_page.dart
        widgets/
          validate_word_card.dart
          meaning_check_card.dart
          vocabulary_check_result_card.dart
    vocabulary_test/
      application/
        vocabulary_test_list_controller.dart
        vocabulary_test_attempt_controller.dart
      presentation/
        vocabulary_test_list_page.dart
        vocabulary_test_preview_page.dart
        vocabulary_test_attempt_page.dart
        vocabulary_test_result_page.dart
        vocabulary_test_history_page.dart
        widgets/
          vocabulary_generated_test_card.dart
          vocabulary_attempt_history_list.dart
```

Nguyên tắc:

- `core/` chỉ giữ API, model, query params và normalization
- `features/` giữ controller + UI flow
- review result và test result phải reuse những gì đã có ở phase 3 khi hợp lý, không dựng result architecture riêng

## 9. Route Contract Đề Xuất

### 9.1. Route thật nên có sau phase này

- `/dictionary`
- `/dictionary/word/:wordId`
- `/dictionary/review`
- `/dictionary/review/result/:sessionId`
- `/vocabulary/check`
- `/vocabulary-tests`
- `/vocabulary-tests/:testId`
- `/vocabulary-tests/attempts/:attemptId`
- `/vocabulary-tests/history`

### 9.2. Alias nên support để tương thích web và notification/actionUrl cũ

- `/vocabulary` -> `/vocabulary-tests`
- `/history` -> `/vocabulary-tests/history`
- `/review` -> `/dictionary/review`

### 9.3. Điều chỉnh cần làm trong route contract hiện tại

`lib/core/navigation/app_route_contract.dart` hiện mới support:

- `/dictionary`
- `/dictionary/review`
- `/dictionary/review/result/:sessionId`

Phase 6 cần mở rộng:

- `supportedAppRoutePatterns`
- `learningSessionRoutePatterns`
- `reviewRoutePatterns`
- `_routeAliases`

để vocabulary surfaces mới đi qua cùng normalize/redirect path như các phase trước.

## 10. API/Domain Contract Cần Dựng

### 10.1. Dictionary foundation

Mobile cần mirror các khả năng web đang dùng:

- search words
- load stats
- toggle favorite
- add word
- get word detail

Nếu current mobile app đã có shared API client nhưng chưa có dictionary module, đây là vertical đầu tiên cần dựng đầy đủ từ domain tới UI.

### 10.2. Review loop

Contract tối thiểu nên bám:

- `GET /api/records/review-words?filter={filter}&limit={limit}`
- `GET /api/records/review-counts`
- `POST /api/reviews`
- `GET /api/reviews/last`

Review submit cần map được sang:

- session summary
- accuracy / correct count / reviewed count
- compare with last session nếu backend trả đủ
- retry wrong / retry all nếu business rule còn giữ trên web

### 10.3. Vocabulary tests

Contract bám trực tiếp `docs/vocabulary-test-fe-handoff.md`.

Các model tối thiểu:

- generated test summary
- generated test detail
- start attempt response
- attempt submission payload
- attempt result detail
- attempt history item

### 10.4. Vocabulary check

Vì chưa có handoff riêng, phần này nên đi theo rule:

- ưu tiên reuse cùng service/backend đang được web gọi
- nếu web đang đi qua nhiều helper rời (`translateApi`, `openClaw`, `dictionaryApi`), mobile cần chốt lại adapter gọn hơn trước khi code UI

Kết luận kỹ thuật:

- đây là sub-slice cần confirm contract sớm
- không nên để màn hình hoàn toàn phụ thuộc vào UI inference

## 11. UX Delivery Theo Từng Surface

### 11.1. Dictionary page

Dictionary page trên mobile không nên chỉ là list phẳng. Nó cần có:

- hero/tóm tắt stats
- search
- filter cơ bản
- saved words grid/list
- CTA vào review
- CTA sang vocabulary check và vocabulary tests

### 11.2. Review session

Review session nên là flow thật, không còn placeholder:

- load due words
- card-based prompt/answer interaction
- progress indicator
- submit session
- open shared result / recap

### 11.3. Vocabulary check

Flow tối thiểu:

1. nhập English word
2. validate word
3. nhập nghĩa tiếng Việt
4. check answer
5. hiển thị explanation / alternatives
6. save vào dictionary nếu user muốn

### 11.4. Vocabulary tests

Flow chuẩn:

1. list các đề đã generate
2. mở generate sheet
3. tạo đề bằng AI
4. preview test detail
5. start attempt
6. làm bài
7. submit
8. xem result
9. xem history attempts

## 12. Tích Hợp Với Spine Phase 3-5

### 12.1. Result journey

Không phải mọi màn result đều cần ép vào `ResultJourneyPage`, nhưng phase 3 đã cho mobile một contract hữu ích.

Rule đề xuất:

- dictionary review result: tiếp tục reuse result journey spine
- vocabulary test result: có page riêng theo test semantics, nhưng CTA và analytics nên align với result journey patterns

### 12.2. Recommendation

Recommendation/action resolver cần map được thêm:

- `VOCABULARY_TEST`
- `VOCABULARY_CHECK`
- `VOCAB_REVIEW`
- `VOCAB_MICRO_SESSION`

vào route thật thay vì fallback vào `/dictionary`.

### 12.3. Notification và push

Notification open router và push open router nên support:

- reminder vào `/dictionary/review`
- campaign vào `/vocabulary-tests`
- deep link vào specific attempt/result nếu backend gửi

### 12.4. Gamification

Review session và vocabulary test completion cần giữ khả năng:

- nhận XP
- phản ánh vào XP history
- tạo continuation sang leaderboard motivation

## 13. Analytics Đề Xuất

Nếu backend analytics contract chưa chốt thêm enum mới, phase 6 nên đi theo nguyên tắc bảo thủ:

- reuse event semantics đang có cho learning start / completion / abandoned
- chỉ thêm enum mới khi backend hoặc product đã chốt rõ

Các event có thể đề xuất, nhưng cần align trước:

- `VOCABULARY_CHECK_STARTED`
- `VOCABULARY_CHECK_COMPLETED`
- `VOCABULARY_TEST_GENERATED`
- `VOCABULARY_TEST_STARTED`
- `VOCABULARY_TEST_COMPLETED`
- `VOCABULARY_TEST_RESUMED`

## 14. Thứ Tự Triển Khai Khuyến Nghị

Không nên build phase 6 một lần. Nên chia làm 5 slice.

### Slice 1. Dictionary foundation

- dựng `core/dictionary/*`
- thay `DictionaryPage` placeholder bằng page thật
- support stats, search, list, favorite, detail

### Slice 2. Real review session

- thay `/dictionary/review` placeholder bằng flow review thật
- submit review session
- nối lại sang result journey hiện có

### Slice 3. Vocabulary check

- dựng service/controller cho word validation + meaning check
- thêm `/vocabulary/check`
- nối save word vào dictionary

### Slice 4. AI-generated vocabulary tests

- dựng list/generate/preview/attempt/result/history
- thêm route contract và alias tương ứng

### Slice 5. Retention integration và polish

- thêm recommendation mapping
- thêm notification/push routing
- thêm home/profile entry points nếu còn thiếu
- rà lại analytics và XP surface

## 15. Definition Of Done

Phase 6 được coi là hoàn thành khi:

- `/dictionary` không còn là placeholder
- `/dictionary/review` không còn là placeholder
- user có thể review thật và xem result
- `/vocabulary/check` usable end-to-end
- `/vocabulary-tests` usable end-to-end
- route alias cũ vẫn mở đúng màn mới
- recommendation/notification có thể đưa user vào vocabulary flows mới
- `flutter analyze` pass
- `flutter test` pass với test coverage tối thiểu cho model normalization và controller logic

## 16. Rủi Ro Và Điểm Cần Chốt Sớm

### 16.1. Vocabulary check chưa có handoff API riêng

Đây là rủi ro lớn nhất của phase 6.

Cần chốt sớm:

- endpoint nào là source of truth cho validate / check / explanation
- có bắt buộc auth không
- response shape ổn định tới mức nào

### 16.2. Web có một số màn history/review mang dấu vết local-storage hoặc desktop interaction

Ví dụ `History.jsx` và một phần review flow trên web có thể phản ánh legacy path hoặc UX thiên desktop.

Kết luận:

- mobile không nên copy UI web một cách máy móc
- nên copy business contract và flow semantics, không copy layout

### 16.3. Review result semantics cần align với result spine hiện có

Nếu review session submit trả data quá khác result snapshot contract hiện tại, có thể cần:

- page riêng cho review result
- hoặc adapter layer chuyển response sang completion snapshot shape

Điểm này nên được quyết định ngay từ đầu, trước khi code UI.

## 17. Kết Luận

Phase 6 hợp lý nhất sau khi đối chiếu toàn bộ docs và code là:

`Vocabulary Mastery, Dictionary, And AI Assessment`

Đây là phase:

- có source of truth đủ mạnh từ web và backend
- bám sát khoảng trống lớn nhất của mobile hiện tại
- tận dụng trực tiếp spine phase 3-5
- tạo ra vertical học tập thật đầu tiên trên mobile thay vì chỉ mở rộng retention shell

Nếu cần tách nhỏ để delivery an toàn, nên chốt thứ tự:

1. dictionary foundation
2. real review session
3. vocabulary check
4. vocabulary tests
5. retention integration
