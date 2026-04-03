# Flutter Mobile Phase 7 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-6-vocabulary-mastery-assessment-handoff.md`.

Nếu phase 3-6 đã khóa được:

- result journey và notification re-entry
- recommendation và retention surfaces
- leaderboard, XP history và push re-engagement
- vocabulary vertical hoàn chỉnh gồm dictionary, review, vocabulary check và AI vocabulary tests

thì phase 7 là lớp giúp mobile đi từ `app đã có daily learning loop mạnh` sang `app có productive skills loop thật cho writing và speaking như web`.

Trọng tâm của phase này là:

- writing tasks, writing submission và writing history
- speaking topics, speaking attempt và speaking history
- guided speaking conversation
- custom speaking conversation
- async grading states, result revisit và notification-driven comeback cho productive skills

## 1. Kết Luận Kiến Trúc Sau Khi Đối Chiếu Web Và Mobile Hiện Tại

Sau khi rà soát docs, web FE và mobile code hiện tại, có 8 kết luận quan trọng.

### 1.1. Sau phase 6, mobile đã có đủ spine để gánh productive skills loop

Mobile hiện đã có:

- app shell và route contract ổn định
- learning action resolver
- result journey page cho writing / speaking / custom conversation
- notification center, push open router và re-entry flow
- recommendation và flagship retention entry points

Điều này có nghĩa phase 7 không phải dựng nền mới. Nó chủ yếu là thay phần placeholder bằng workflow thật.

### 1.2. Writing và speaking trên mobile hiện vẫn là khoảng trống lớn nhất còn lại

Các điểm neo hiện tại bên mobile:

- `lib/features/writing/writing_page.dart` vẫn là `FeatureLandingPage`
- nhiều route `/writing/*` trong `lib/app/router/app_router.dart` vẫn dùng placeholder hoặc reserved page
- `lib/features/speaking/speaking_page.dart` vẫn là `FeatureLandingPage`
- `/speaking/history`, `/speaking/conversation/*`, `/custom-speaking/*` vẫn chưa có flow thật

Kết luận:

- sau phase 6, productive skills là cụm gap rõ nhất giữa mobile và web
- đây là lát cắt có impact lớn hơn so với tiếp tục vá từng route lẻ

### 1.3. Web đã có một cụm productive skills khá trưởng thành và liên kết chặt

Các điểm bám chính bên web:

- `src/pages/writing/WritingListPage.jsx`
- `src/pages/writing/WritingTaskDetailPage.jsx`
- `src/pages/writing/WritingTaskPage.jsx`
- `src/pages/writing/WritingSubmissionPage.jsx`
- `src/pages/writing/WritingHistoryPage.jsx`
- `src/pages/speaking/SpeakingListPage.jsx`
- `src/pages/speaking/SpeakingPracticePage.jsx`
- `src/pages/speaking/SpeakingResultPage.jsx`
- `src/pages/speaking/SpeakingHistoryPage.jsx`
- `src/pages/speaking/SpeakingConversationPage.jsx`
- `src/pages/speaking/SpeakingConversationResultPage.jsx`
- `src/pages/speaking/SpeakingConversationHistoryPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationChatPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationResultPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationHistoryPage.jsx`

Kết luận:

- phase 7 có reference implementation đủ rõ
- không cần tự phát minh UX mới cho mobile

### 1.4. Writing và speaking nên đi chung một phase vì cùng chia sẻ productive-skill semantics

Hai cụm này cùng có:

- task/topic list
- detail hoặc prompt shell
- attempt/submission
- async grading hoặc pending state
- result revisit
- history page
- notification comeback sau grading

Nếu tách writing và speaking thành hai phase quá xa nhau:

- mobile sẽ có hai implementation pattern khác nhau cho cùng một nhóm hành vi
- async grading, polling và revisit flow dễ bị nhân đôi logic

### 1.5. Custom speaking conversation đủ trưởng thành để nằm trong cùng phase, không nên đẩy thành phase riêng

Điểm bám quan trọng:

- `docs/custom-speaking-conversation-fe.md`
- `src/api/speakingApi.js`
- web đã có start, turn submission, finish, detail, history, result

Điều này khác với một feature exploratory chưa chốt contract.

Kết luận:

- custom speaking nên là sub-slice của speaking cluster trong phase 7
- không cần tách thành roadmap riêng nếu mục tiêu là product parity có kiểm soát

### 1.6. Productive skills loop tận dụng trực tiếp hạ tầng notification và result journey từ phase 3-5

Các flow quan trọng đã có nền:

- `WRITING_SUBMISSION`
- `SPEAKING_ATTEMPT`
- `CUSTOM_SPEAKING_CONVERSATION`
- notification khi grading xong
- push open routing về route đích

Kết luận:

- phase 7 phải reuse completion snapshot và notification action flow
- không nên dựng “result page riêng ngoài hệ thống”

### 1.7. IELTS full test parity chưa phải lựa chọn tốt nhất cho phase này

Dù web cũng có khối IELTS reading/listening trưởng thành, nhưng cụm đó là một bài toán khác:

- session timing nghiêm ngặt hơn
- nhiều question type
- transcript / answer review semantics riêng
- state machine làm bài phức tạp hơn

Trong khi writing + speaking là một cluster chặt hơn:

- đều là productive practice
- đều dựa trên AI grading và result revisit
- đều nối thẳng vào push/notification lifecycle hiện có

### 1.8. Phase 7 hợp lý nhất là một phase productive skills depth

Tên ngắn gọn nên dùng:

`Phase 7 - Productive Skills, Writing, And Speaking`

Nếu muốn tên kỹ thuật hơn:

`Phase 7 - Writing Tasks, Speaking Practice, Conversation Loops, And Async Grading Re-entry`

## 2. Phase Này Là Gì

Nếu phase 6 là:

- app cho user học và kiểm tra từ vựng hằng ngày

thì phase 7 là:

- app cho user luyện đầu ra thật qua writing và speaking, nhận feedback, quay lại xem kết quả và tiếp tục tiến bộ trên mobile

Sau phase này, mobile nên có một productive loop hoàn chỉnh:

1. chọn writing task hoặc speaking topic
2. thực hành và submit
3. chờ AI grading nếu cần
4. quay lại result đúng màn
5. mở history để xem tiến bộ hoặc làm lại
6. với speaking, có thêm guided conversation và freestyle custom conversation

## 3. Source Of Truth Cần Bám

### 3.1. Mobile docs đã có

- `docs/flutter-mobile-base-handoff.md`
- `docs/flutter-mobile-phase-2-daily-loop-handoff.md`
- `docs/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`
- `docs/flutter-mobile-phase-4-recommendation-retention-report-handoff.md`
- `docs/flutter-mobile-phase-5-gamification-push-growth-handoff.md`
- `docs/flutter-mobile-phase-6-vocabulary-mastery-assessment-handoff.md`

### 3.2. Docs contract chính cho phase này

- `../en-practice/docs/custom-speaking-conversation-fe.md`
- `../en-practice/docs/result-journey-reminder-api-fe-handoff.md`
- `../en-practice/docs/notification-fe.md`
- `../en-practice/docs/recommendation-flagship-api-fe-handoff.md`
- `../en-practice/docs/project-summary-and-roadmap.md`

### 3.3. Mã nguồn web cần coi là reference implementation

- `../en-practice/src/api/writingApi.js`
- `../en-practice/src/api/speakingApi.js`
- `../en-practice/src/pages/writing/WritingListPage.jsx`
- `../en-practice/src/pages/writing/WritingTaskDetailPage.jsx`
- `../en-practice/src/pages/writing/WritingTaskPage.jsx`
- `../en-practice/src/pages/writing/WritingSubmissionPage.jsx`
- `../en-practice/src/pages/writing/WritingHistoryPage.jsx`
- `../en-practice/src/pages/speaking/SpeakingListPage.jsx`
- `../en-practice/src/pages/speaking/SpeakingPracticePage.jsx`
- `../en-practice/src/pages/speaking/SpeakingResultPage.jsx`
- `../en-practice/src/pages/speaking/SpeakingHistoryPage.jsx`
- `../en-practice/src/pages/speaking/SpeakingConversationPage.jsx`
- `../en-practice/src/pages/speaking/SpeakingConversationResultPage.jsx`
- `../en-practice/src/pages/speaking/SpeakingConversationHistoryPage.jsx`
- `../en-practice/src/pages/speaking/CustomSpeakingConversationPage.jsx`
- `../en-practice/src/pages/speaking/CustomSpeakingConversationChatPage.jsx`
- `../en-practice/src/pages/speaking/CustomSpeakingConversationResultPage.jsx`
- `../en-practice/src/pages/speaking/CustomSpeakingConversationHistoryPage.jsx`

### 3.4. Mã nguồn mobile cần coi là điểm neo hiện tại

- `lib/app/router/app_router.dart`
- `lib/core/navigation/app_route_contract.dart`
- `lib/core/navigation/learning_action_resolver.dart`
- `lib/core/push/push_open_router.dart`
- `lib/features/results/presentation/result_journey_page.dart`
- `lib/features/writing/writing_page.dart`
- `lib/features/speaking/speaking_page.dart`
- `lib/features/learning/learning_session_placeholder_page.dart`

## 4. Vì Sao Phase Này Phải Đi Sau Phase 6

Phase 7 phụ thuộc trực tiếp vào những gì phase trước đã dựng:

- writing và speaking result phải reuse result journey đã có
- notification grading complete phải đi qua action resolver và push router đã khóa từ phase 3-5
- recommendation surfaces từ phase 4 có thể đẩy user vào writing hoặc daily speaking
- XP / leaderboard từ phase 5 giúp productive tasks có reward loop rõ hơn
- vocabulary phase 6 đã hoàn thiện daily micro-learning, nên phase 7 là bước hợp lý để mở rộng sang deep practice

Nếu làm phase này sớm hơn:

- productive result sẽ bị tách khỏi shared completion system
- grading notification sẽ phải vá lại sau
- app sẽ có nhiều vertical nhưng thiếu phần “output skill” để tạo perceived value cao

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app mạnh về retention và vocabulary thành app có productive practice loop thật cho writing và speaking.

### 5.2. Technical goal

Dựng shared contracts cho:

- writing tasks / detail / submit / submission history
- speaking topics / detail / submit / attempt history
- guided conversation start / turn / detail / history
- custom conversation start / turn / finish / detail / history
- audio upload, transcript capture và speech analytics payload
- async grading states, revisit và notification-driven reopen

### 5.3. UX goal

Sau phase này, user nên làm được luồng sau:

1. mở Writing để lọc task và xem task detail
2. vào writing session, viết bài và submit
3. xem submission result hoặc pending grading state
4. mở Writing history để revisit bài cũ
5. mở Speaking để chọn topic hoặc quick entry
6. ghi âm hoặc nhập transcript, submit speaking attempt
7. xem speaking result và history
8. bắt đầu guided conversation hoặc custom speaking conversation
9. tiếp tục hội thoại, finish và quay lại result/historical detail

## 6. In Scope

- writing list page với filter, stats và highest score snapshot
- writing task detail page
- writing session page thật thay cho placeholder
- writing submit flow và pending/graded states
- writing submission result / revisit
- writing history page
- speaking topic list page với filter, stats và highest score snapshot
- speaking practice page thật với audio capture hoặc transcript fallback nếu stack hiện tại cho phép
- speaking attempt submit
- speaking result page
- speaking history page
- guided speaking conversation start / turn / result / history
- custom speaking conversation setup / chat / finish / result / history
- polling hoặc refresh strategy cho async grading
- push / notification / recommendation re-entry vào productive routes khi phù hợp

## 7. Out Of Scope

- IELTS reading/listening full test parity
- listening transcript review flow
- advanced streaming voice synthesis polish nếu mobile stack chưa sẵn
- offline recording queue hoặc offline-first upload sync
- social sharing writing/speaking result
- teacher review workflow
- analytics enum mới nếu backend chưa chốt thêm cho productive skills
- deep coach overlays vượt quá contract web hiện tại

## 8. Kiến Trúc Flutter Đề Xuất Cho Phase Này

```txt
lib/
  core/
    writing/
      writing_api.dart
      writing_models.dart
      writing_query_params.dart
    speaking/
      speaking_api.dart
      speaking_models.dart
      speaking_query_params.dart
      speaking_audio_upload_api.dart
      speech_analytics_models.dart
    speaking_conversation/
      speaking_conversation_api.dart
      speaking_conversation_models.dart
    custom_speaking/
      custom_speaking_api.dart
      custom_speaking_models.dart
      custom_speaking_ws_client.dart
  features/
    writing/
      application/
        writing_list_controller.dart
        writing_task_controller.dart
        writing_submission_controller.dart
        writing_history_controller.dart
      presentation/
        writing_list_page.dart
        writing_task_detail_page.dart
        writing_task_page.dart
        writing_submission_page.dart
        writing_history_page.dart
        widgets/
          writing_task_card.dart
          writing_filter_bar.dart
          writing_editor.dart
          writing_pending_state.dart
    speaking/
      application/
        speaking_list_controller.dart
        speaking_practice_controller.dart
        speaking_result_controller.dart
        speaking_history_controller.dart
      presentation/
        speaking_list_page.dart
        speaking_practice_page.dart
        speaking_result_page.dart
        speaking_history_page.dart
        widgets/
          speaking_topic_card.dart
          speaking_recorder_card.dart
          speech_analytics_panel.dart
    speaking_conversation/
      application/
        speaking_conversation_controller.dart
        speaking_conversation_history_controller.dart
      presentation/
        speaking_conversation_page.dart
        speaking_conversation_result_page.dart
        speaking_conversation_history_page.dart
    custom_speaking/
      application/
        custom_speaking_setup_controller.dart
        custom_speaking_chat_controller.dart
        custom_speaking_history_controller.dart
      presentation/
        custom_speaking_page.dart
        custom_speaking_chat_page.dart
        custom_speaking_result_page.dart
        custom_speaking_history_page.dart
```

Nguyên tắc:

- `core/` chỉ giữ API, model, query params, upload contract và normalization
- `features/` giữ orchestration, page state và widget tree
- guided conversation và custom conversation là hai sub-modules riêng, tránh nhồi chung controller
- result pages vẫn đi qua cùng result/revisit semantics đã có của app

## 9. Route Contract Cần Hoàn Thiện

Các route phase 7 cần được coi là first-class mobile routes:

- `/writing`
- `/writing/history`
- `/writing/task/:taskId`
- `/writing/task/:taskId/take`
- `/writing/submission/:submissionId`
- `/speaking`
- `/speaking/practice/:id`
- `/speaking/result/:id`
- `/speaking/history`
- `/speaking/conversation/:topicId`
- `/speaking/conversation/result/:id`
- `/speaking/conversation/history`
- `/custom-speaking`
- `/custom-speaking/conversation/:id`
- `/custom-speaking/result/:id`
- `/custom-speaking/history`

Alias normalization cần giữ:

- `/writing/tasks/:taskId` -> `/writing/task/:taskId`
- `/writing/submissions/:submissionId` -> `/writing/submission/:submissionId`
- `/speaking/attempts/:id` -> `/speaking/result/:id`
- `/speaking/daily-prompt/:id` -> `/speaking?mode=quick`
- `/custom-speaking-conversations/:id` -> `/custom-speaking/result/:id`

## 10. Delivery Slices Đề Xuất

### 10.1. Slice A - Writing foundation

- writing list
- writing detail
- writing take page
- submission result
- history

### 10.2. Slice B - Speaking single-attempt loop

- speaking topic list
- practice page
- audio upload / transcript fallback
- submit attempt
- result / history

### 10.3. Slice C - Guided conversation

- start conversation từ topic
- send turns
- conversation result
- conversation history

### 10.4. Slice D - Custom speaking conversation

- setup page
- chat page
- finish flow
- result / history

### 10.5. Slice E - Async grading comeback loop

- pending state refresh
- notification-driven reopen
- result refresh / retry semantics

## 11. API Contract Notes Cần Chốt Trước Khi Code

### 11.1. Writing

Contract web hiện cho thấy các endpoint chính:

- `GET /api/writing/tasks`
- `GET /api/writing/tasks/{taskId}`
- `POST /api/writing/tasks/highest-scores`
- `POST /api/writing/tasks/{taskId}/submit`
- `GET /api/writing/submissions`
- `GET /api/writing/submissions/{submissionId}`
- `GET /api/user/results/writing/{submissionId}/completion-snapshot`

Mobile cần xác nhận thêm:

- payload result khi submission đang `PENDING` hoặc `GRADING`
- essay length constraints nếu backend có enforce

### 11.2. Speaking

Contract web hiện cho thấy các endpoint chính:

- `GET /api/speaking/topics`
- `GET /api/speaking/topics/{topicId}`
- `POST /api/speaking/topics/highest-scores`
- `POST /api/speaking/topics/{topicId}/submit`
- `GET /api/speaking/attempts`
- `GET /api/speaking/attempts/{attemptId}`
- `POST /api/speaking/upload-audio`
- `GET /api/user/results/speaking/{attemptId}/completion-snapshot`

Mobile cần xác nhận thêm:

- audio upload mime types / file size
- transcript-only fallback có được chấp nhận như web không
- speech analytics fields nào bắt buộc

### 11.3. Guided speaking conversation

Contract bám theo `src/api/speakingApi.js`:

- `POST /api/speaking/conversations/start?topicId={topicId}`
- `POST /api/speaking/conversations/{conversationId}/turn`
- `GET /api/speaking/conversations/{conversationId}`
- `GET /api/speaking/conversations`

Điểm cần chốt:

- refresh cadence khi grading result sau khi conversation complete
- REST-only hay cần WS ở mobile phase đầu

### 11.4. Custom speaking conversation

Contract đã có tài liệu riêng:

- `POST /api/custom-speaking-conversations/start`
- `POST /api/custom-speaking-conversations/{id}/turn`
- `POST /api/custom-speaking-conversations/{id}/finish`
- `GET /api/custom-speaking-conversations/{id}`
- `GET /api/custom-speaking-conversations`
- `GET /api/user/results/custom-conversations/{id}/completion-snapshot`

Ghi chú:

- phase đầu có thể ưu tiên REST polling trước nếu WS delivery trên mobile làm tăng rủi ro
- nếu app đã sẵn STOMP stack ổn định thì có thể bật realtime turn streaming ở slice D

## 12. UX Và State Notes Quan Trọng

- writing task page phải có auto-save local draft hoặc tối thiểu giữ state khi app background ngắn hạn
- speaking practice page phải có transcript fallback nếu speech-to-text hoặc audio recorder không khả dụng
- pending grading state phải rõ ràng, không để user tưởng submit thất bại
- history pages phải ưu tiên fast resume / revisit thay vì chỉ list tĩnh
- conversation pages phải hiển thị rõ số turn đã dùng và trạng thái `IN_PROGRESS` / `COMPLETED` / `GRADING` / `GRADED`

## 13. Analytics Gợi Ý

Nếu backend/analytics contract đã sẵn, có thể đo tối thiểu:

- writing task opened
- writing submission started / submitted / revisited
- speaking topic opened
- speaking attempt started / submitted / revisited
- conversation started / finished / reopened from notification
- custom conversation started / finished / graded reopened

Nếu analytics enum backend chưa khóa, mobile chỉ nên giữ instrumentation ở mức recommendation thay vì hard-code schema mới.

## 14. Definition Of Done

Phase 7 được xem là xong khi:

1. user có thể hoàn thành writing loop end-to-end trên mobile
2. user có thể hoàn thành speaking single-attempt loop end-to-end trên mobile
3. user có thể làm guided conversation và custom conversation với result/history rõ ràng
4. pending grading và completed grading đều có re-entry path đúng qua notification/result journey
5. route alias từ web sang mobile cho productive skills không còn rơi vào placeholder

## 15. Rủi Ro Và Cách Giảm Rủi Ro

### 15.1. Audio và speech stack có thể là phần rủi ro nhất

Giảm rủi ro bằng cách:

- chốt transcript-only fallback ngay từ đầu
- triển khai upload contract trước, tối ưu recorder sau

### 15.2. Async grading dễ tạo cảm giác app lỗi

Giảm rủi ro bằng cách:

- tách rõ `submitted`, `grading`, `graded`, `failed`
- cho phép refresh result từ history hoặc notification

### 15.3. Conversation module dễ phình scope

Giảm rủi ro bằng cách:

- phase đầu ưu tiên parity theo web hiện tại
- không thêm coaching overlay hoặc streaming polish ngoài contract

## 16. Kết Luận

Sau khi mobile đã hoàn thành phase 6, bước tiếp theo hợp lý nhất không phải là mở rộng thêm nhiều vertical nhỏ, mà là khóa cụm productive skills còn đang trống.

Vì vậy, phase 7 nên là:

`Phase 7 - Productive Skills, Writing, And Speaking`

Đây là phase giúp mobile tiến từ:

- học đều, ôn đều và có retention loop

thành:

- có thực hành đầu ra thật, có grading thật, có revisit thật và có perceived value đủ mạnh để cạnh tranh như một learning product hoàn chỉnh.
