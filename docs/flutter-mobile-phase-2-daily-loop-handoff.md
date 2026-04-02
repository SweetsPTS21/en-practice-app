# Flutter Mobile Phase 2 Handoff

Tài liệu này mô tả phase tiếp theo sau khi mobile đã hoàn tất base `theme + localization`.

Mục tiêu của phase này là dựng được một phiên bản app usable đầu tiên cho dự án học tiếng Anh, bám sát kiến trúc web hiện tại về:

- auth/session restore
- app shell và router
- deep link và fallback routing
- Home launchpad cho daily learning loop
- continue learning, daily plan, quick practice, progress snapshot
- analytics semantics cho learning flow

Tài liệu này không nhằm mô tả toàn bộ UI chi tiết của từng module IELTS, Writing, Speaking hay Dictionary. Nó chốt phần kiến trúc và contract để mobile có thể mở app, đăng nhập, vào Home, học tiếp, và giữ đúng mental model của web.

## 1. Phase Này Là Gì

Nếu `flutter-mobile-base-handoff.md` là nền thiết kế hệ thống, thì phase này là nền hành vi sản phẩm.

Sau phase này, mobile cần đạt được:

- app mở lên và restore session ổn định
- user đăng nhập xong vào đúng shell của app
- Home hiển thị CTA học chính và các block học ngắn
- các CTA điều hướng theo đúng contract `actionUrl` và `resumeUrl`
- mobile hiểu thế nào là `learning session`, `resume`, `daily task`
- các event analytics chính có chỗ bám ngay từ đầu

## 2. Source Of Truth Cần Bám

Mobile cần coi các tài liệu và file sau là nguồn tham chiếu chính cho phase này:

- `docs/mobile/flutter-mobile-base-handoff.md`
- `docs/auth-and-security.md`
- `docs/home-launchpad-api-fe-handoff.md`
- `docs/daily-learning-retention-phase-roadmap.md`
- `src/api/dashboardApi.js`
- `src/features/learning/learningAnalytics.js`
- `src/features/learning/learningAction.js`
- `src/pages/dashboard/HomePage.jsx`
- `src/features/daily-plan/DailyPlanDrawer.jsx`
- `src/App.jsx`

## 3. Kết Luận Kiến Trúc Quan Trọng

### 3.1. Mobile không nên bắt đầu bằng nhiều màn tính năng rời rạc

Nếu dựng riêng lẻ `Dictionary`, `IELTS`, `Writing`, `Speaking` trước khi có daily loop chung, mobile sẽ nhanh rơi vào tình trạng:

- có nhiều màn nhưng thiếu CTA học chính
- không biết khi mở app thì user nên làm gì tiếp theo
- deep link/notification sau này phải refactor lớn

### 3.2. Home không phải dashboard chỉ để xem số

Theo roadmap hiện tại, Home là launchpad học ngay. Vì vậy mobile phải ưu tiên:

- `Continue Learning`
- `Daily Learning Plan`
- `Quick Practice`
- `Progress Snapshot`

### 3.3. `actionUrl` và `resumeUrl` là contract điều hướng, không phải text để hiển thị

Mobile nên coi các field route từ backend là source of truth cho navigation:

- `resumeUrl`
- `actionUrl`

Không nên tự suy diễn route bằng title hoặc type nếu route hợp lệ đã được backend trả về.

### 3.4. `reason` là machine-readable, không phải display text

Các giá trị như:

- `UNFINISHED_ATTEMPT`
- `DUE_REVIEW`
- `WEAK_SKILL`
- `SHORT_RECOMMENDATION`
- `GET_STARTED`

được dùng cho tracking và branching nhẹ. Mobile không nên hard-code UI text trực tiếp từ `reason`.

### 3.5. Session continuity là bắt buộc, không phải nice-to-have

Roadmap và tài liệu auth đều nhấn mạnh:

- app phải restore session ổn định
- access token hết hạn phải refresh được
- app phải có khả năng resume flow sau app restart hoặc cold start ở mức hợp lý

## 4. Mục Tiêu Cụ Thể Của Phase

### 4.1. Product goal

Biến mobile từ “bộ khung có style” thành “app học được ngay”.

### 4.2. Technical goal

Dựng lớp nền đủ để các phase sau như notification, result journey, recommendation, weekly report có thể cắm vào mà không phá kiến trúc.

### 4.3. UX goal

Khi user mở app, trong dưới 1 phút họ có thể:

1. đăng nhập hoặc được restore session
2. thấy CTA học chính
3. bấm vào bài phù hợp
4. đi đúng tới màn học hoặc màn fallback hợp lệ

## 5. Phạm Vi Phase

### 5.1. In scope

- auth session mới theo mô hình `accessToken + refreshToken`
- bootstrap app và splash/loading gate
- router bằng `go_router`
- route guard cho authenticated/unauthenticated flow
- Home launchpad
- fetch các endpoint dashboard cốt lõi
- action routing và fallback routing
- launch context cho learning session
- analytics event cơ bản cho daily loop
- daily plan drawer hoặc bottom sheet bản đầu

### 5.2. Out of scope

- notification center đầy đủ
- FCM push
- realtime STOMP/WebSocket
- result journey hoàn chỉnh
- weekly report hoàn chỉnh
- recommendation engine đa điểm chạm
- toàn bộ chi tiết UI/logic của từng module học

## 6. Deliverables Phase Này

Mobile nên chốt được các deliverable sau:

1. `AppBootstrap`
    - load theme/locale prefs
    - load auth session
    - resolve bootstrap state

2. `AuthController`
    - login
    - register nếu team muốn mở sớm
    - refresh token
    - logout
    - restore session

3. `AppRouter`
    - shell route
    - auth guard
    - support deeplink nội bộ

4. `LearningNavigation`
    - normalize route nội bộ
    - check route supported
    - resolve fallback route
    - phân biệt route nào là `learning session`

5. `HomeLaunchpad`
    - continue learning card
    - daily plan preview
    - quick practice rail/list
    - progress snapshot

6. `DailyPlanSheet`
    - xem danh sách task trong ngày
    - start task
    - hiển thị completion cục bộ ở mức base

7. `LearningAnalytics`
    - track event open/click/start chính

## 7. Cấu Trúc Thư Mục Flutter Đề Xuất Cho Phase Này

Phase trước đã chốt nền `theme` và `l10n`. Phase này nên mở rộng như sau:

```txt
lib/
  app/
    app.dart
    bootstrap/
      app_bootstrap.dart
      bootstrap_state.dart
    router/
      app_router.dart
      route_names.dart
      route_guards.dart
  core/
    auth/
      app_auth_controller.dart
      app_auth_state.dart
      app_auth_storage.dart
      app_auth_api.dart
      token_refresh_coordinator.dart
    analytics/
      learning_analytics_service.dart
      learning_event.dart
    navigation/
      app_route_contract.dart
      learning_action_resolver.dart
      learning_launch_store.dart
      supported_routes.dart
    network/
      api_client.dart
      api_response.dart
  features/
    auth/
      presentation/
        login_page.dart
    home/
      data/
        dashboard_api.dart
        home_launchpad_repository.dart
        models/
          continue_learning_response.dart
          daily_learning_plan_response.dart
          quick_practice_response.dart
          progress_snapshot_response.dart
      presentation/
        home_page.dart
        widgets/
          continue_learning_card.dart
          daily_plan_preview.dart
          quick_practice_section.dart
          progress_snapshot_card.dart
          daily_plan_sheet.dart
      application/
        home_launchpad_controller.dart
        home_launchpad_state.dart
```

## 8. Auth Và Session Contract Mobile Cần Bám

Mobile nên bám đúng hướng trong `docs/auth-and-security.md`.

### 8.1. Session model cần có

```dart
class AppAuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final AppUser user;
}
```

### 8.2. Bootstrap flow cần đạt

```txt
if no refresh token
-> signed out

if access token valid
-> call /auth/me
-> signed in

if access token expired and refresh token valid
-> call /auth/refresh
-> save new session
-> call /auth/me
-> signed in

if refresh fail
-> clear auth state
-> signed out
```

### 8.3. Quy tắc cho mobile

- Không tiếp tục mô hình `token` đơn lẻ cũ.
- Không coi cached `user` là nguồn xác thực cuối cùng.
- Token refresh phải có cơ chế chống refresh song song.
- Nếu app resume từ background và access token hết hạn, phải refresh trước khi gọi protected endpoint.
- Với Flutter mobile, nên ưu tiên `flutter_secure_storage` cho session nhạy cảm thay vì `SharedPreferences`.

## 9. Router Và Route Contract

Mobile nên có danh sách route nội bộ tương đương web ngay từ phase này.

### 9.1. Supported app routes nên giữ tương thích semantics với web

```txt
/home
/dictionary
/dictionary/review
/ielts
/ielts/test/:testId
/ielts/take/:attemptId
/ielts/result/:attemptId
/writing
/writing/history
/writing/task/:taskId
/writing/task/:taskId/take
/writing/submission/:submissionId
/speaking
/speaking/practice/:id
/speaking/result/:id
/speaking/history
/speaking/conversation/:topicId
/speaking/conversation/result/:id
/custom-speaking
/custom-speaking/conversation/:id
/custom-speaking/result/:id
/weekly-report
/challenges
/notifications
/settings
```

Mobile không nhất thiết phải implement hết UI trong phase này, nhưng router contract nên dành chỗ cho các route này để action routing không bị đứt tư duy.

### 9.2. Session-start routes

Các route sau cần được coi là `learning session route` vì web đang tracking theo tư duy này:

```txt
/dictionary/review
/ielts/take/:attemptId
/writing/task/:taskId/take
/speaking/practice/:id
/custom-speaking/conversation/:id
```

Khi user đi vào các route này từ launch context phù hợp, mobile nên có chỗ bắn event `started`.

### 9.3. Internal route aliases nên support

Để bám sát web, mobile nên normalize một số alias:

```txt
/dashboard -> /home
/writing/submissions/:id -> /writing/submission/:id
/ielts/attempts/:id -> /ielts/result/:id
/speaking/attempts/:id -> /speaking/result/:id
/ielts/tests/:id/resume -> /ielts/test/:id
/practice/reading/matching-headings -> /ielts?mode=mini&skill=READING
/speaking/daily-prompt/:id -> /speaking?mode=quick
/custom-speaking-conversations/:id -> /custom-speaking/result/:id
```

## 10. Action Resolver Contract

Mobile nên có một lớp tương đương `resolveLearningActionTarget()` của web.

### 10.1. Input

```dart
class LearningActionInput {
  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final String? module;
  final Map<String, dynamic>? metadata;
  final String defaultRoute;
}
```

### 10.2. Output

```dart
class LearningActionTarget {
  final LearningActionKind kind;
  final String href;
  final bool usedFallback;
  final bool isLearningSession;
}
```

### 10.3. Resolution rules

1. Nếu `actionUrl` là external URL thì trả về external target.
2. Nếu `actionUrl` map được sang detail route hợp lệ thì dùng route đó.
3. Nếu `actionUrl` là internal route supported thì dùng luôn.
4. Nếu là pattern resume đặc biệt của IELTS thì map sang `/ielts/take/:attemptId`.
5. Nếu route không hợp lệ thì resolve fallback theo `referenceType`, sau đó `module`, sau đó `defaultRoute`.

### 10.4. Reference fallback cần giữ tương thích

```txt
WRITING_SUBMISSION -> /writing
WRITING_TASK -> /writing
SPEAKING_ATTEMPT -> /speaking
SPEAKING_TOPIC -> /speaking
DAILY_SPEAKING_PROMPT -> /speaking?mode=quick
CUSTOM_SPEAKING_CONVERSATION -> /custom-speaking
IELTS_ATTEMPT -> /ielts
VOCAB_REVIEW -> /dictionary
VOCAB_REVIEW_SESSION -> /dictionary
VOCAB_MICRO_SESSION -> /dictionary/review?mode=micro
READING_DRILL -> /ielts?mode=mini&skill=READING
DAILY_PLAN_ITEM -> /home
STREAK -> /home
```

### 10.5. Module fallback cần giữ tương thích

```txt
WRITING -> /writing
SPEAKING -> /speaking
IELTS -> /ielts
VOCABULARY -> /dictionary
DICTIONARY -> /dictionary
VOCAB -> /dictionary
```

## 11. Home Launchpad Contract

Mobile phase này nên implement 4 endpoint trước:

```txt
GET /api/user/dashboard/continue-learning
GET /api/user/dashboard/daily-learning-plan
GET /api/user/dashboard/quick-practice
GET /api/user/dashboard/progress-snapshot
```

Có thể để sẵn interface cho:

```txt
GET /api/user/dashboard/reminder-banner
GET /api/user/dashboard/flagship-retention
GET /api/user/dashboard/recent-activities
```

nhưng chưa bắt buộc phải polish toàn bộ trong phase này.

### 11.1. Continue Learning

Mobile nên coi đây là CTA chính duy nhất của Home.

Model gợi ý:

```dart
class ContinueLearningItem {
  final String source;
  final String title;
  final String description;
  final String resumeUrl;
  final int? estimatedMinutes;
  final String reason;
  final int? priority;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;
}
```

### 11.2. Daily Learning Plan

Mobile nên render tối đa 3 task ngắn ngay trên Home, và có sheet/page để mở rộng.

```dart
class DailyLearningPlanItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final String ctaLabel;
  final String actionUrl;
  final int? estimatedMinutes;
  final int? priority;
  final String reason;
}
```

### 11.3. Quick Practice

Quick practice là danh sách các phiên ngắn. Không nên biến thành module riêng phức tạp ở phase này.

### 11.4. Progress Snapshot

Đây là block feedback nhẹ để user thấy hôm nay mình đang đi tới đâu. Không cần over-design, nhưng phải bám đúng payload.

## 12. Learning Launch Context

Web đang dùng `rememberLearningLaunch()` để lưu ngữ cảnh trước khi điều hướng vào phiên học. Mobile nên giữ cùng tư duy.

### 12.1. Model đề xuất

```dart
class LearningLaunchContext {
  final String source;
  final String? module;
  final String route;
  final String? referenceType;
  final String? referenceId;
  final String? reason;
  final int? estimatedMinutes;
  final Map<String, dynamic>? metadata;
  final bool started;
  final DateTime launchedAt;
  final DateTime? startedAt;
}
```

### 12.2. Nơi dùng

- continue learning card
- daily task click
- quick practice click
- reminder banner
- notification phase sau
- recommendation phase sau

### 12.3. Gợi ý persistence

- Nếu chỉ cần trong runtime, có thể giữ bằng provider state.
- Nếu muốn survive app kill ngắn hạn, có thể persist nhẹ bằng storage cục bộ.
- Nếu persist, nên giữ semantics gần web với các key:
    - `en_practice_learning_pending_launch`
    - `en_practice_daily_task_completion`
    - `en_practice_recent_learning_feedback`

Không bắt buộc phải dùng đúng storage backend của web, nhưng semantics nên giống nhau.

## 13. Analytics Contract Cần Có Từ Phase Này

Mobile nên có service gửi:

```txt
POST /api/user/analytics/learning-events
```

### 13.1. Event names nên implement ngay

```txt
HOME_OPENED
CONTINUE_LEARNING_CLICKED
DAILY_TASK_CLICKED
DAILY_TASK_COMPLETED
LEARNING_STARTED
LEARNING_COMPLETED
LEARNING_ABANDONED
RESUME_STARTED
NOTIFICATION_TO_SESSION_STARTED
```

### 13.2. Event names có thể chuẩn bị sẵn nhưng chưa cần full flow

```txt
RESULT_NEXT_ACTION_CLICKED
ERROR_REVIEW_OPENED
REVIEW_AGAIN_CLICKED
NOTIFICATION_OPENED
NOTIFICATION_CLICKED
REMINDER_BANNER_CLICKED
RECOMMENDATION_CLICKED
RECOMMENDATION_COMPLETED
SPEAKING_PROMPT_STARTED
SPEAKING_PROMPT_COMPLETED
VOCAB_MICRO_SESSION_STARTED
VOCAB_MICRO_SESSION_COMPLETED
```

### 13.3. Quy tắc tracking

- `HOME_OPENED` khi Home launchpad render thành công cho user signed-in.
- `CONTINUE_LEARNING_CLICKED` khi user bấm CTA chính.
- `RESUME_STARTED` nếu CTA là resume một phiên đang dang dở.
- `DAILY_TASK_CLICKED` khi user bấm task trong kế hoạch ngày.
- `LEARNING_STARTED` khi user thực sự vào session route phù hợp.

Không nên bắn event ngay khi chỉ mới resolve được route. Event start nên gắn với việc user đã vào route học thật.

## 14. Màn Hình Mobile Nên Có Ở Cuối Phase

### 14.1. Bắt buộc

- splash/bootstrap gate
- login page
- home page
- settings base page

### 14.2. Tối thiểu để điều hướng không gãy

- dictionary landing placeholder hoặc page thật nếu đã có
- ielts landing placeholder
- writing landing placeholder
- speaking landing placeholder

### 14.3. Tối thiểu để support resume route

- `dictionary/review`
- `ielts/take/:attemptId`
- `writing/task/:taskId/take`
- `speaking/practice/:id`
- `custom-speaking/conversation/:id`

Nếu một session page chưa kịp hoàn thiện nghiệp vụ, vẫn nên có page shell hoặc placeholder hợp lệ để verify navigation và analytics contract.

## 15. UI Shell Cho Home Mobile

### 15.1. Thứ tự block nên bám web

1. continue learning
2. daily learning plan
3. quick practice
4. progress snapshot

### 15.2. Yêu cầu UI

- CTA chính phải nằm above-the-fold trên mobile.
- Không để quá nhiều card ngang hàng ở màn đầu.
- Daily plan nên ưu tiên scan nhanh, không buộc mở sâu mới thấy hành động.
- Empty state phải có fallback `get started`, không để Home trở thành màn trắng.

### 15.3. Tinh thần thiết kế

Theme và l10n vẫn đọc từ nền phase trước. Home phase này phải dùng token thật, không dùng widget style tạm thời tách rời design system.

## 16. Quy Tắc Không Được Làm Sai

- Không hard-code route fallback rải rác ở từng widget. Resolver phải nằm ở một lớp chung.
- Không để mỗi feature tự gọi analytics theo kiểu khác nhau.
- Không bỏ qua `reason`, `referenceType`, `referenceId` khi dựng launch context.
- Không gộp auth bootstrap vào `main.dart` theo kiểu side effect khó test.
- Không dùng màn Home như nơi nhồi toàn bộ module của sản phẩm.
- Không để CTA Home điều hướng vào route không có trong route contract.
- Không coi `progress snapshot` là số liệu trang trí, vì đây là phần của retention loop.

## 17. Thứ Tự Thực Thi Khuyến Nghị

1. dựng auth session model và secure storage
2. dựng API client + refresh coordinator
3. dựng bootstrap gate và auth restore flow
4. dựng `go_router` + route guard + route contract
5. dựng `learning_action_resolver.dart`
6. dựng dashboard API và model
7. dựng Home launchpad page
8. dựng learning launch store + analytics service
9. nối tracking cho continue learning và daily plan
10. dựng placeholder cho các session route tối thiểu

Nếu làm ngược, team sẽ rất dễ có UI Home nhưng không có khả năng điều hướng/resume thật.

## 18. Done Checklist Cho Phase Này

- user có thể login và vào app shell
- app restart vẫn restore session nếu refresh token còn hạn
- có refresh token flow cơ bản
- Home gọi được:
    - `/user/dashboard/continue-learning`
    - `/user/dashboard/daily-learning-plan`
    - `/user/dashboard/quick-practice`
    - `/user/dashboard/progress-snapshot`
- continue learning render đúng CTA chính
- daily plan render được tối đa 3 item
- quick practice render được danh sách ngắn
- progress snapshot render được số liệu cơ bản
- mọi CTA đi qua action resolver chung
- route nội bộ được normalize/fallback đúng
- có launch context trước khi vào learning session
- có tracking tối thiểu cho:
    - `HOME_OPENED`
    - `CONTINUE_LEARNING_CLICKED`
    - `DAILY_TASK_CLICKED`
    - `RESUME_STARTED`
    - `LEARNING_STARTED`
- Home có loading, empty, error state nhất quán
- CTA chính trên Home nằm above-the-fold trên mobile

## 19. Gợi Ý Tên Phase Cho Team

Tên ngắn gọn, đúng tinh thần sản phẩm:

`Phase 2 - Daily Loop Foundation`

Nếu muốn đặt tên kỹ thuật hơn:

`Phase 2 - App Shell, Session, Launchpad, And Learning Navigation`

## 20. Chốt Phạm Vi

Sau phase trước, mobile đã có ngôn ngữ thiết kế và localization. Phase tiếp theo không nên nhảy ngay vào nhiều màn chức năng sâu, mà nên khóa 4 thứ trước:

1. session ổn định
2. router và deep link đúng semantics
3. Home launchpad có CTA học chính
4. launch context và analytics cho learning flow

Khi 4 thứ này đúng, các phase sau như notification, result journey, recommendation và gamification sẽ cắm vào mobile rất tự nhiên mà không phải phá kiến trúc đã dựng.
