# Flutter Mobile Phase 3 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-2-daily-loop-handoff.md`.

Mục tiêu của phase này là đưa mobile đi tiếp từ `app học được ngay` sang `app biết khép vòng sau khi học xong và biết kéo user quay lại đúng lúc`.

Phase này bám theo kiến trúc web hiện tại ở 3 lớp đã tương đối rõ:

- result journey sau khi user hoàn thành bài
- reminder/banner và action routing cho re-entry
- notification center + realtime notification + deep link điều hướng lại vào learning flow

Tài liệu này không cố gom cả recommendation flagship, weekly report, challenge hay achievements vào chung một phase. Những phần đó đã tồn tại trên web, nhưng hợp lý hơn cho phase sau.

## 1. Kết Luận Kiến Trúc Sau Khi Rà Soát Toàn Dự Án

Sau khi đối chiếu mã nguồn hiện tại, có 6 kết luận quan trọng:

### 1.1. Web đang có một lõi học tập dùng chung, không còn là các màn rời rạc

Các lớp lõi hiện tại nằm ở:

- `src/features/learning/learningAnalytics.js`
- `src/features/learning/learningAction.js`
- `src/features/learning/resultJourneyNavigation.js`
- `src/features/learning/CompletionSnapshotSection.jsx`

Điều này có nghĩa mobile không nên implement result CTA, banner CTA và notification CTA theo từng feature page riêng lẻ. Chúng phải đi qua một lớp chung giống web.

### 1.2. Result journey đã là contract thật trên web, không còn chỉ là tài liệu

Web hiện đã gọi completion snapshot ở các module:

- IELTS
- Writing
- Speaking
- Custom Speaking Conversation

Các điểm bám hiện có:

- `src/api/ieltsApi.js`
- `src/api/writingApi.js`
- `src/api/speakingApi.js`
- `src/pages/ielts/TestResultPage.jsx`
- `src/pages/writing/WritingSubmissionPage.jsx`
- `src/pages/speaking/SpeakingResultPage.jsx`
- `src/pages/speaking/CustomSpeakingConversationResultPage.jsx`

Lưu ý quan trọng:

- docs backend đã có contract cho vocabulary review session completion snapshot
- nhưng web hiện chưa rollout rõ một wrapper API/page tương ứng cho vocabulary result journey

Mobile nên giữ model đủ rộng để nhận cả vocabulary snapshot, nhưng rollout UI ban đầu có thể ưu tiên 4 module đã đang chạy rõ trên web.

### 1.3. Reminder banner contract đã sẵn ở data layer nhưng UI web còn rollout dở

`HomePage.jsx` hiện đã gọi:

- `dashboardApi.getReminderBanner()`

Nhưng block render banner vẫn đang comment out.

Kết luận:

- backend contract và helper navigation đã đủ ổn để mobile dùng
- nhưng mobile không cần coi UI web hiện tại là bản final cho visual/layout

### 1.4. Notification stack trên web đã hoạt động ở mức feature hoàn chỉnh

Các lớp đang có:

- `src/features/notification/NotificationProvider.jsx`
- `src/hooks/useNotificationRealtime.js`
- `src/hooks/useNotificationAction.js`
- `src/features/notification/components/NotificationBell.jsx`
- `src/features/notification/components/NotificationToastHost.jsx`
- `src/features/notification/pages/NotificationCenterPage.jsx`

Điều này cho thấy notification ở web không chỉ là inbox đọc tin, mà đã là một action surface có:

- unread badge
- realtime subscribe
- toast
- notification click tracking
- navigation fallback
- re-entry vào learning session

### 1.5. Auth/session/network của web đã đủ chín để mobile reuse semantics

Các lớp nền hiện tại:

- `src/main.jsx`
- `src/providers/AppProviders.jsx`
- `src/contexts/AuthContext.jsx`
- `src/api/axiosClient.js`
- `src/App.jsx`

Mobile phase 3 không cần thay đổi mental model đã chốt ở phase 2:

- access token + refresh token
- bootstrap restore session
- auth logout event
- app shell + guarded routes

Phase này chỉ mở rộng thêm lớp `post-completion` và `re-entry`.

### 1.6. Recommendation/weekly report/challenge/achievement đã có trên web nhưng nên để phase sau

Web hiện đã có:

- `RecommendationCard`
- `FlagshipRetentionPanel`
- `WeeklyReportPage`
- `WeeklyChallengePage`

Nhưng nếu kéo hết các phần này vào ngay phase 3 của mobile, phạm vi sẽ phình quá lớn và làm mờ trọng tâm chính của phase kế tiếp.

## 2. Phase Này Là Gì

Nếu phase 2 là:

- session ổn định
- router ổn định
- Home launchpad có CTA học chính

thì phase 3 là:

- học xong phải thấy bước tiếp theo
- rời app rồi phải quay lại được đúng entry point
- notification phải dẫn về đúng hành động, không chỉ mở inbox

Tên ngắn gọn nên dùng:

`Phase 3 - Result Journey And Notification Re-entry Loop`

Nếu muốn tên product-facing hơn:

`Phase 3 - Complete, Reflect, And Come Back`

## 3. Source Of Truth Cần Bám

### 3.1. Mobile docs đã có

- `docs/mobile/flutter-mobile-base-handoff.md`
- `docs/mobile/flutter-mobile-phase-2-daily-loop-handoff.md`

### 3.2. Docs contract cần dùng trực tiếp cho phase này

- `docs/result-journey-reminder-api-fe-handoff.md`
- `docs/notification-fe.md`
- `docs/auth-and-security.md`
- `docs/home-launchpad-api-fe-handoff.md`

### 3.3. Mã nguồn web cần coi là reference implementation

- `src/features/learning/learningAnalytics.js`
- `src/features/learning/learningAction.js`
- `src/features/learning/resultJourneyNavigation.js`
- `src/features/learning/CompletionSnapshotSection.jsx`
- `src/hooks/useNotificationAction.js`
- `src/features/notification/NotificationProvider.jsx`
- `src/features/notification/pages/NotificationCenterPage.jsx`
- `src/hooks/useNotificationRealtime.js`
- `src/api/dashboardApi.js`
- `src/api/notificationApi.js`
- `src/api/ieltsApi.js`
- `src/api/writingApi.js`
- `src/api/speakingApi.js`
- `src/pages/dashboard/HomePage.jsx`

## 4. Vì Sao Phase Này Phải Đi Sau Phase 2

Phase 2 đã chốt:

- app shell
- auth restore
- Home launchpad
- action resolver cơ bản
- learning launch context cơ bản

Khoảng trống lớn tiếp theo của mobile là:

- user hoàn thành một activity nhưng không có recap chung
- chưa có lớp CTA sau result để nối sang hành động kế tiếp
- chưa có reminder/banner để kéo user quay lại đúng thời điểm
- notification chưa thành action loop

Nếu bỏ qua phase này và nhảy thẳng sang recommendation/weekly report/challenge, mobile sẽ có thêm nhiều surface nhưng vẫn thiếu đoạn giữa quan trọng của retention loop:

`start -> complete -> reflect -> next action -> re-entry`

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app “mở vào để làm bài” thành app “hoàn thành một phiên học xong biết ngay nên làm gì tiếp”.

### 5.2. Technical goal

Dựng shared contracts cho:

- completion snapshot
- result CTA
- reminder/banner CTA
- notification CTA
- notification-driven session start

### 5.3. UX goal

Sau phase này, user nên làm được luồng sau:

1. hoàn thành một activity
2. thấy recap tiến bộ và next action
3. đóng app
4. nhận reminder hoặc notification
5. chạm vào notification và quay lại đúng flow học

## 6. In Scope

- completion snapshot cho result pages
- shared result summary section
- result CTA primary/secondary
- review/open-again tracking từ result
- reminder banner trên Home
- notification bell/inbox page bản mobile
- notification preferences cơ bản
- realtime unread count và realtime new notification
- notification toast/in-app notice
- shared action resolver cho result/banner/notification
- learning launch context cho re-entry
- analytics event cho post-completion và notification journey

## 7. Out Of Scope

- recommendation primary/feed
- recommendation dismiss/snooze feedback
- flagship retention block
- weekly report page
- weekly challenge page
- achievements page
- full social/gamification rollout
- FCM push handling ngoài app-level integration cần thiết

## 8. Cấu Trúc Flutter Đề Xuất Cho Phase Này

```txt
lib/
  core/
    learning_journey/
      completion_snapshot_models.dart
      result_action_models.dart
      result_action_resolver.dart
      learning_launch_store.dart
      learning_event_service.dart
      review_route_contract.dart
    notifications/
      notification_api.dart
      notification_models.dart
      notification_preferences_models.dart
      notification_realtime_client.dart
      notification_action_resolver.dart
      notification_center_store.dart
      notification_badge_store.dart
  features/
    results/
      presentation/
        widgets/
          completion_snapshot_section.dart
          completion_metric_card.dart
          completion_action_card.dart
      application/
        result_journey_controller.dart
    home/
      presentation/
        widgets/
          reminder_banner.dart
    notifications/
      presentation/
        notification_inbox_page.dart
        widgets/
          notification_bell_button.dart
          notification_list.dart
          notification_list_item.dart
          notification_settings_card.dart
          notification_toast_host.dart
      application/
        notification_center_controller.dart
        notification_settings_controller.dart
```

Điểm quan trọng:

- không nhét logic result CTA vào từng feature result page
- không nhét logic notification click vào từng list item
- không để Home banner tự resolve route riêng

## 9. Shared Navigation Và Launch Context

Phase 2 đã giới thiệu tư duy `rememberLearningLaunch()`. Phase 3 phải giữ tiếp và mở rộng tư duy này.

### 9.1. Shared action resolver vẫn là một lớp duy nhất

Result CTA, reminder banner và notification item đều phải đi qua cùng nguyên tắc:

1. ưu tiên `actionUrl`
2. nếu route invalid hoặc stale, dùng `metadata.fallbackActionUrl`
3. nếu chưa có, fallback theo `referenceType`
4. nếu vẫn chưa có, fallback theo `module`
5. cuối cùng fallback `/home`

### 9.2. Session-start routes cần giữ cùng semantics phase 2

```txt
/dictionary/review
/ielts/take/:attemptId
/writing/task/:taskId/take
/speaking/practice/:id
/custom-speaking/conversation/:id
```

Nếu target cuối cùng là một route thuộc nhóm này, mobile phải có chỗ:

- remember launch context
- mark started khi user đã thật sự vào route
- emit event started phù hợp

### 9.3. Review routes nên được phân biệt với session-start routes

Web hiện có logic review route riêng cho:

```txt
/ielts/result/:attemptId
/writing/submission/:submissionId
/speaking/result/:id
/custom-speaking/result/:id
```

Mobile nên giữ chỗ cho tư duy này để:

- mở lại review từ result CTA
- tracking `ERROR_REVIEW_OPENED`
- không nhầm review route với learning session route

### 9.4. Launch context model nên tiếp tục dùng

```dart
class LearningLaunchContext {
  final String source;
  final String? module;
  final String route;
  final String? referenceType;
  final String? referenceId;
  final String? taskId;
  final String? taskTitle;
  final String? reason;
  final int? estimatedMinutes;
  final int? priority;
  final Map<String, dynamic>? metadata;
  final bool started;
  final DateTime launchedAt;
  final DateTime? startedAt;
}
```

### 9.5. Entry points cần ghi launch context trong phase này

- result primary action
- result secondary action
- reminder banner
- notification center item
- notification toast

## 10. Result Journey Contract

## 10.1. Endpoints

Mobile phase này nên support:

```txt
GET /api/user/results/ielts/{attemptId}/completion-snapshot
GET /api/user/results/writing/{submissionId}/completion-snapshot
GET /api/user/results/speaking/{attemptId}/completion-snapshot
GET /api/user/results/custom-conversations/{conversationId}/completion-snapshot
GET /api/user/results/vocabulary/review-sessions/{sessionId}/completion-snapshot
```

## 10.2. Model gợi ý

```dart
class CompletionSnapshot {
  final String module;
  final String referenceType;
  final String referenceId;
  final String completionTitle;
  final String? primaryScoreLabel;
  final double? primaryScore;
  final String? primaryScoreDisplay;
  final int? xpEarned;
  final bool? streakKept;
  final TodayGoalProgress? todayGoalProgress;
  final List<CompletionScoreSummary> scoreSummary;
  final List<CompletionDelta> deltas;
  final List<ImprovementItem> improvements;
  final ResultNextAction? nextAction;
  final ResultNextAction? secondaryAction;
  final Map<String, dynamic> metadata;
}
```

## 10.3. Rendering order nên bám web

1. `completionTitle`
2. `primaryScoreLabel + primaryScoreDisplay`
3. XP + streak chip
4. `scoreSummary`
5. `deltas`
6. `improvements`
7. `todayGoalProgress`
8. `nextAction`
9. `secondaryAction`

Không nên để từng feature page tự tính:

- delta
- XP
- streak kept
- next action

## 10.4. Result action handling

Mobile nên có helper tương đương `triggerResultJourneyAction()` của web.

Nó phải làm đủ 4 việc:

1. resolve target route
2. bắn analytics click
3. remember launch context nếu target là learning session
4. navigate/fallback

## 10.5. Phạm vi rollout thực tế

Nên ưu tiên rollout theo thứ tự:

1. IELTS result
2. Writing submission result
3. Speaking result
4. Custom speaking conversation result
5. Vocabulary review result nếu team đã có screen phù hợp

## 11. Reminder Banner Contract

## 11.1. Endpoint

```txt
GET /api/user/dashboard/reminder-banner
```

## 11.2. Model gợi ý

```dart
class ReminderBanner {
  final String type;
  final String title;
  final String description;
  final String ctaLabel;
  final String actionUrl;
  final String reason;
  final int? priority;
  final int? estimatedMinutes;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;
}
```

## 11.3. Banner types cần sẵn sàng support

```txt
STREAK_RISK
GRADING_RESULT_READY
DAILY_PLAN_ONE_TASK_LEFT
DUE_VOCAB_QUICK_REVIEW
WEEKLY_REPORT_READY
REENGAGEMENT_3D
REENGAGEMENT_7D
```

## 11.4. Behavior rule

- nếu `data == null`: không render banner
- nếu `actionUrl` invalid: ưu tiên `metadata.fallbackActionUrl`
- nếu cả 2 không hợp lệ: fallback `/home`
- nếu banner trùng hẳn CTA chính trên Home, mobile có thể ẩn bớt một surface

## 11.5. Ghi chú khi đối chiếu web

Web đã fetch banner nhưng chưa render chính thức ở `HomePage.jsx`.

Điều này không có nghĩa mobile phải hoãn. Nó chỉ có nghĩa:

- visual web chưa chốt
- còn semantics backend và routing contract đã đủ dùng

## 12. Notification Center Contract

## 12.1. REST APIs

```txt
GET /api/notifications
GET /api/notifications/unread-count
PATCH /api/notifications/{id}/read
PATCH /api/notifications/read-all
DELETE /api/notifications/{id}
GET /api/notification-preferences
PUT /api/notification-preferences
```

## 12.2. Realtime contracts

Handshake:

```txt
/ws/realtime-chat
```

Topics:

```txt
/topic/notifications/{userId}/new
/topic/notifications/{userId}/unread-count
```

## 12.3. Notification item model

```dart
class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String? body;
  final String priority;
  final bool isRead;
  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? readAt;
}
```

## 12.4. Metadata retention fields cần đọc được

```txt
reason
estimatedMinutes
triggerType
fallbackActionUrl
ctaLabel
```

## 12.5. Notification action handling

Mobile nên có một lớp tương đương `useNotificationAction()` của web.

Khi user bấm notification:

1. mark as read nếu cần
2. resolve action target
3. bắn `NOTIFICATION_OPENED`
4. bắn `NOTIFICATION_CLICKED`
5. nếu target là learning session, remember launch context với `entryPoint = notification`
6. navigate tới target

## 12.6. In-app toast / foreground notice

Web đang có `NotificationToastHost` để mở notice ngay khi có realtime item mới.

Mobile phase này nên có bản tương đương:

- nếu app foreground và có notification realtime mới
- hiển thị lightweight in-app card/snackbar/banner
- chạm vào đó sẽ đi qua cùng notification action handler

## 12.7. Notification settings tối thiểu

Mobile nên support:

- `allowPush`
- `allowEmail`
- `allowVocabularyReminder`
- `allowGradingResult`
- `allowAdminBroadcast`

Không cần over-design page này trong phase 3. Chỉ cần:

- load đúng
- update đúng
- save state rõ

## 13. Analytics Contract Cho Phase Này

Phase 2 đã có learning analytics cơ bản. Phase 3 phải mở rộng theo post-completion và re-entry.

## 13.1. Event mobile cần bắn

```txt
RESULT_NEXT_ACTION_CLICKED
ERROR_REVIEW_OPENED
REVIEW_AGAIN_CLICKED
NOTIFICATION_OPENED
NOTIFICATION_CLICKED
REMINDER_BANNER_CLICKED
NOTIFICATION_TO_SESSION_STARTED
```

## 13.2. Event backend/web đang auto-log, mobile không nên double-log

```txt
RESULT_OPENED
RESULT_NEXT_ACTION_SERVED
REMINDER_BANNER_SERVED
NOTIFICATION_SENT
NOTIFICATION_DELIVERED
```

## 13.3. Quy tắc tracking quan trọng

- `NOTIFICATION_TO_SESSION_STARTED` chỉ bắn khi user đã thật sự vào learning session route
- không bắn event start ngay lúc mới click banner/notification/result CTA
- result review và result next action là hai hành vi khác nhau, không gộp chung

## 14. Màn Hình Nên Có Ở Cuối Phase

### 14.1. Bắt buộc

- shared completion snapshot section
- result integration cho các module đã rollout
- Home reminder banner
- notification inbox page
- notification settings section

### 14.2. Tối thiểu để re-entry loop không gãy

- bell button hoặc app-bar action cho unread count
- foreground in-app notification surface
- notification deep link handler

### 14.3. Không bắt buộc phải hoàn thiện trong phase này

- recommendation feed page
- weekly report page
- challenge page
- achievements gallery

## 15. Thứ Tự Thực Thi Khuyến Nghị

1. dựng shared models cho completion snapshot, reminder banner, notification item
2. dựng shared action resolver cho result/banner/notification
3. dựng learning launch store mở rộng cho notification entry
4. rollout result journey UI cho 1 module pilot
5. rollout result journey cho các module còn lại
6. dựng reminder banner trên Home
7. dựng notification center REST flow
8. dựng realtime unread count + realtime new item
9. nối foreground toast
10. nối analytics và verify không double count

Nếu làm ngược, team rất dễ có notification UI nhưng click vào lại không giữ được learning context.

## 16. Done Checklist Cho Phase Này

- completion snapshot render được đúng structure chung
- result CTA primary/secondary đi qua shared resolver
- review action từ result có tracking riêng
- Home render được reminder banner khi `data != null`
- banner click có fallback an toàn nếu target stale
- có notification inbox page với:
    - list
    - unread count
    - mark read
    - mark all read
    - delete
- có notification preferences cơ bản
- có realtime unread count
- có realtime new notification handling
- click notification dùng cùng action resolver chung
- notification có thể đưa user vào learning session và giữ launch context
- `NOTIFICATION_TO_SESSION_STARTED` chỉ bắn khi user đã vào session thật
- không double-log các event served do backend đã tự log

## 17. Ranh Giới Sang Phase Sau

Sau phase này, mobile sẽ có đầy đủ loop:

- start
- complete
- next action
- reminder
- notification re-entry

Phase sau mới nên kéo thêm:

- recommendation surfaces
- flagship retention block
- weekly report
- weekly challenge
- achievements

Lý do:

- các phần đó sẽ hưởng lợi rất nhiều khi shared result/reminder/notification/action-resolver đã ổn
- nếu làm sớm hơn, mobile sẽ có nhiều surface nhưng thiếu xương sống journey

## 18. Chốt Phạm Vi

Sau khi rà soát toàn bộ kiến trúc hiện tại, phase tiếp theo hợp lý nhất cho mobile không phải là thêm nhiều module mới, mà là khóa lớp trung gian quan trọng giữa `học` và `quay lại học`.

4 thứ phase 3 phải chốt trước:

1. result journey chung
2. reminder banner có action thật
3. notification center là action surface, không chỉ inbox
4. re-entry tracking dựa trên launch context và shared resolver

Khi 4 thứ này đúng, các lớp recommendation, weekly report, challenge và achievement ở phase sau sẽ cắm vào mobile rất tự nhiên, đúng với kiến trúc web hiện tại và không phải refactor lại navigation/analytics loop.
