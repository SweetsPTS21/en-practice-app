# Flutter Mobile Phase 5 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-4-recommendation-retention-report-handoff.md`.

Nếu phase 4 đã khóa được:

- recommendation surfaces
- flagship retention
- weekly report
- weekly challenge
- achievements

thì phase 5 là lớp giúp mobile chuyển từ `giữ user học đều` sang `khuếch đại động lực bằng social proof, progress visibility và re-engagement ở cấp thiết bị`.

Trọng tâm của phase này là:

- leaderboard và XP history
- leaderboard summary trên Home và Profile
- push permission và FCM token lifecycle
- push-driven re-entry và campaign semantics

## 1. Kết Luận Kiến Trúc Sau Khi Đối Chiếu Web Hiện Tại

Sau khi rà soát mã nguồn web và docs còn lại, có 6 kết luận quan trọng cho phase tiếp theo.

### 1.1. Leaderboard trên web đã là feature hoàn chỉnh, không còn ở mức ý tưởng

Các điểm bám chính:

- `src/api/leaderboardApi.js`
- `src/pages/dashboard/LeaderboardWidget.jsx`
- `src/pages/leaderboard/LeaderboardPage.jsx`
- `src/pages/leaderboard/XpHistoryPage.jsx`
- `src/components/profile/page/ProfileLeaderboardSnapshot.jsx`
- `docs/leaderboard-frontend.md`

Điều này có nghĩa mobile không nên coi leaderboard là “extra page sẽ làm sau”. Nó đã là một phần của product layer hiện tại trên web.

### 1.2. Leaderboard không chỉ là một page, mà là một lớp social proof nhiều điểm chạm

Web hiện đã có leaderboard ở 4 điểm:

- widget trên Home
- snapshot trong Profile
- page leaderboard full
- page XP history

Kết luận:

- mobile phase 5 không nên chỉ làm `/leaderboard`
- cần rollout cả các bề mặt tóm tắt lẫn màn chi tiết

### 1.3. Push engagement trên web đã có hạ tầng thật nhưng chưa được đưa vào roadmap mobile thành một phase riêng

Các điểm bám chính:

- `src/utils/notificationHelper.js`
- `src/firebase.js`
- `public/firebase-messaging-sw.js`
- `src/api/authApi.js`
- `src/App.jsx`

Web đã có:

- xin quyền notification
- lấy FCM token
- gửi FCM token lên backend
- foreground handling
- background service worker

Nhưng trong roadmap mobile trước đó, phần này mới chỉ được nhắc rải rác chứ chưa được gom thành một phase delivery cụ thể.

### 1.4. Push ở phase này phải gắn với notification action flow từ phase 3

Push không nên là một nhánh mới song song.

Khi user chạm push notification:

- phải quay lại cùng action resolver
- phải giữ được learning launch context nếu đi vào learning session
- phải bắn được analytics re-entry giống notification center/in-app notification

Nói cách khác, phase 5 phải reuse spine từ phase 3 thay vì tự dựng flow push riêng.

### 1.5. Web hiện chưa có một leaderboard analytics contract riêng đủ rõ

Qua docs và mã nguồn hiện tại:

- chưa thấy một enum analytics riêng cho leaderboard như đã có cho learning journey/recommendation

Kết luận:

- mobile phase 5 không nên tự nghĩ ra analytics enum mới cho leaderboard nếu backend chưa chốt
- nếu cần đo, nên tách riêng phần “recommended instrumentation” và ghi rõ cần align backend trước

### 1.6. Sau phase 4, phần còn lại hợp lý nhất chính là gamification layer và device-level engagement

Phase 4 đã chốt:

- recommendation
- flagship loops
- weekly report
- weekly challenge
- achievements

Phần còn lại của web có tính hệ thống nhất là:

- XP/leaderboard/rank movement
- push delivery, permission, token sync, deep link
- growth/re-engagement campaigns dựa trên notification infrastructure

Đây là cụm nên thành phase 5, thay vì tách thành nhiều phase nhỏ khó theo dõi.

## 2. Phase Này Là Gì

Nếu phase 4 là:

- app biết đề xuất học gì tiếp theo
- app kể lại tiến bộ theo nhịp tuần

thì phase 5 là:

- app cho user thấy mình đang đứng ở đâu so với người khác và với chính mình
- app có thể chủ động quay lại thiết bị của user qua push
- app biến progress và competition thành động lực quay lại

Tên ngắn gọn nên dùng:

`Phase 5 - Gamification, Leaderboard, And Push Re-engagement`

Nếu muốn tên kỹ thuật hơn:

`Phase 5 - Leaderboard, XP History, FCM Lifecycle, And Push-Driven Growth Loop`

## 3. Source Of Truth Cần Bám

### 3.1. Mobile docs đã có

- `docs/mobile/flutter-mobile-base-handoff.md`
- `docs/mobile/flutter-mobile-phase-2-daily-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-4-recommendation-retention-report-handoff.md`

### 3.2. Docs contract chính cho phase này

- `docs/leaderboard-frontend.md`
- `docs/notification-fe.md`
- `docs/project-summary-and-roadmap.md`

### 3.3. Mã nguồn web cần coi là reference implementation

- `src/api/leaderboardApi.js`
- `src/pages/dashboard/LeaderboardWidget.jsx`
- `src/components/profile/page/ProfileLeaderboardSnapshot.jsx`
- `src/pages/leaderboard/LeaderboardPage.jsx`
- `src/pages/leaderboard/XpHistoryPage.jsx`
- `src/pages/leaderboard/MyRankCard.jsx`
- `src/pages/leaderboard/TopThreePodium.jsx`
- `src/utils/notificationHelper.js`
- `src/firebase.js`
- `public/firebase-messaging-sw.js`
- `src/api/authApi.js`
- `src/App.jsx`

## 4. Vì Sao Phase Này Phải Đi Sau Phase 4

Phase 4 đã cho mobile:

- recommendation và flagship entry points
- weekly progress loop
- challenge/achievement motivation layer

Phase 5 mở rộng layer động lực theo hai hướng:

1. social proof và earned progress visibility
2. device-level comeback loop

Nếu làm phase 5 sớm hơn:

- push click sẽ thiếu re-entry spine từ phase 3
- leaderboard sẽ thành page độc lập không nối được vào Home/Profile
- gamification sẽ bị tách khỏi weekly progress/challenge đã có

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app có retention loop cá nhân thành app có thêm động lực cạnh tranh, social proof và khả năng kéo user quay lại trực tiếp trên thiết bị.

### 5.2. Technical goal

Dựng shared contracts cho:

- leaderboard data
- leaderboard summary
- XP history
- push permission state
- FCM token registration/refresh
- push open routing

### 5.3. UX goal

Sau phase này, user nên làm được luồng sau:

1. mở Home và thấy leaderboard snapshot
2. mở Profile và thấy vị trí của mình trong hệ thống
3. vào leaderboard full page để xem thứ hạng
4. mở XP history để hiểu mình nhận reward từ đâu
5. bật push notification
6. chạm push notification và quay lại đúng màn học hoặc result/review liên quan

## 6. In Scope

- leaderboard summary widget trên Home
- leaderboard snapshot trên Profile
- leaderboard full page
- XP history page
- push permission onboarding / prompt strategy
- FCM token fetch + save lên backend
- token refresh/re-register lifecycle
- foreground push handling
- background push open handling
- push deep link routing đi qua shared notification action flow
- admin broadcast và growth campaign semantics ở mức consume/render

## 7. Out Of Scope

- public profile của user khác
- follow/friend/social graph
- chat/community features
- leaderboard analytics enum mới nếu backend chưa chốt
- A/B testing framework cho campaign timing
- advanced campaign editor hoặc remote config platform
- multi-device token management UI cho user

## 8. Kiến Trúc Flutter Đề Xuất Cho Phase Này

```txt
lib/
  core/
    leaderboard/
      leaderboard_api.dart
      leaderboard_models.dart
      xp_history_models.dart
      leaderboard_query_params.dart
    push/
      push_permission_service.dart
      push_token_service.dart
      push_registration_api.dart
      push_message_models.dart
      push_open_router.dart
      push_lifecycle_controller.dart
  features/
    leaderboard/
      presentation/
        widgets/
          leaderboard_summary_widget.dart
          profile_leaderboard_snapshot.dart
          my_rank_card.dart
          top_three_podium.dart
          leaderboard_table.dart
          xp_history_timeline.dart
      application/
        leaderboard_controller.dart
        xp_history_controller.dart
      pages/
        leaderboard_page.dart
        xp_history_page.dart
    notifications/
      application/
        push_entry_controller.dart
      presentation/
        widgets/
          push_permission_sheet.dart
          foreground_push_banner.dart
```

Điểm quan trọng:

- `leaderboard` là một domain riêng
- `push` không nên nhét vào feature notification UI thuần, vì nó có lifecycle cấp app/device

## 9. Leaderboard Contract

## 9.1. Endpoints

```txt
GET /api/leaderboard
GET /api/leaderboard/summary
GET /api/xp/history
```

## 9.2. Query params cho full leaderboard

```txt
period = WEEKLY | MONTHLY | ALL_TIME
scope = GLOBAL | BY_TARGET_BAND
targetBand = optional
page
size
```

## 9.3. Model gợi ý

```dart
class LeaderboardUser {
  final int rank;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final double? targetBand;
  final int xp;
  final int currentStreak;
  final int rankChange;
  final String rankChangeDirection;
}

class MyRankSummary {
  final int rank;
  final int totalParticipants;
  final int xp;
  final int xpToNextRank;
  final int rankChange;
  final String rankChangeDirection;
}

class LeaderboardResponse {
  final MyRankSummary? myRank;
  final List<LeaderboardUser> topUsers;
  final PageInfo page;
}
```

## 9.4. Summary widget contract

`GET /api/leaderboard/summary` nên được dùng cho:

- Home widget
- lightweight surface khác nếu cần

Không nên bắt Home tự fetch full leaderboard chỉ để render top 3 và my rank.

## 9.5. XP history contract

```dart
class XpHistoryEntry {
  final String id;
  final String source;
  final String description;
  final int xp;
  final DateTime earnedAt;
}

class XpHistoryResponse {
  final int totalXP;
  final int weeklyXP;
  final List<XpHistoryEntry> history;
  final PageInfo page;
}
```

## 9.6. Rendering rules

- Home widget chỉ nên hiển thị top 3 + my rank
- Profile snapshot chỉ nên hiển thị rank, xp, xpToNextRank và top 3
- full leaderboard page mới có filter, podium và bảng đầy đủ
- XP history page là nơi kể lại nguồn reward, không cần nhồi thêm recommendation

## 10. Gamification Surfaces Cần Có

## 10.1. Home leaderboard widget

Mục tiêu:

- social proof nhẹ
- tạo CTA sang full leaderboard

Behavior:

- fetch summary riêng
- empty state nếu chưa có dữ liệu
- nếu `myRank == null`, vẫn cho xem top 3 và CTA luyện tập

## 10.2. Profile leaderboard snapshot

Mục tiêu:

- gắn progress cá nhân với competitive context

Behavior:

- dùng data `leaderboardSummary` nếu profile payload đã có
- CTA sang `/leaderboard`

## 10.3. Leaderboard page

Mục tiêu:

- màn gamification full

Sections nên có:

- hero/header
- period selector
- ranking scope selector
- my rank card
- top three podium
- ranking table/list

## 10.4. XP history page

Mục tiêu:

- giải thích vì sao user có XP
- củng cố cảm giác “tiến bộ có ghi nhận”

Sections nên có:

- total XP
- weekly XP
- activity count
- XP timeline

## 11. Push Permission Và FCM Lifecycle Contract

## 11.1. Backend endpoint cần dùng

```txt
POST /api/auth/fcm-token
```

Web hiện gọi qua `authApi.saveFcmToken(fcmToken, os, browser)`.

Với mobile, semantics tương đương nên là:

- save push token kèm platform/device info phù hợp

## 11.2. Flutter stack khuyến nghị

- `firebase_messaging`
- `flutter_local_notifications` nếu cần foreground presentation linh hoạt

## 11.3. Lifecycle cần support

1. app signed-in và push chưa enabled
2. xin permission đúng thời điểm
3. lấy FCM token
4. gửi token lên backend
5. handle token refresh
6. refresh token lại khi app restart hoặc user login lại nếu cần

## 11.4. Permission strategy

Không nên xin quyền push ngay lúc app vừa mở lần đầu một cách mù quáng.

Điểm xin quyền hợp lý hơn:

- sau khi user đã signed-in
- sau khi user đã hoàn thành ít nhất một flow học
- hoặc khi user mở notification settings / prompt được contextualized

## 11.5. Foreground / background / terminated handling

Mobile phase này nên support tối thiểu:

- foreground: hiện in-app banner hoặc local notification nhẹ
- background: tap notification mở app và route đúng
- terminated: cold start từ notification vẫn resolve được target

## 12. Push Routing Và Re-entry Semantics

Phase 5 phải reuse toàn bộ spine từ phase 3.

## 12.1. Push tap không được route riêng bên ngoài notification action flow

Push payload khi mở app nên đi qua cùng logic:

1. parse notification payload
2. resolve `actionUrl`
3. fallback nếu stale
4. remember launch context nếu vào learning session
5. navigate

## 12.2. Push types mobile nên sẵn sàng support

Theo docs và hạ tầng hiện có, tối thiểu nên support:

- grading result ready
- vocab reminder
- streak risk
- weekly report ready
- weekly reward / leaderboard reward
- admin broadcast
- re-engagement 3d / 7d
- recommendation ready nếu backend đã gửi theo contract notification metadata

## 12.3. Admin broadcast

Admin broadcast không nhất thiết mở learning session.

Mobile nên:

- hiển thị trong notification center
- cho phép tap để mở inbox hoặc route cụ thể nếu payload có `actionUrl`
- không ép gắn launch context học tập khi target không phải session route

## 13. Analytics Guidance Cho Phase Này

## 13.1. Điều chưa nên làm

Vì web/docs hiện chưa chốt riêng analytics enum cho leaderboard:

- không tự phát minh `LEADERBOARD_OPENED`, `PODIUM_CLICKED`... nếu backend chưa align

## 13.2. Điều nên làm

- reuse analytics notification mở/click khi push dẫn về notification/action
- với push-driven session start, tiếp tục dùng re-entry semantics từ phase 3
- nếu team muốn thêm leaderboard analytics, phải chốt enum backend trước rồi mới implement

## 13.3. Instrumentation khuyến nghị nhưng chưa coi là contract cứng

Có thể chuẩn bị chỗ hook cho:

- leaderboard page viewed
- xp history page viewed
- push permission granted/denied
- push token synced

Nhưng các event này nên được coi là optional instrumentation layer, không phải base contract của phase.

## 14. Màn Hình Và Surface Nên Có Ở Cuối Phase

### 14.1. Bắt buộc

- Home leaderboard widget
- Profile leaderboard snapshot
- leaderboard full page
- XP history page
- push permission UX cơ bản
- foreground push presentation
- push open routing qua shared resolver

### 14.2. Tối thiểu để device-level engagement không gãy

- token save sau login/permission grant
- token refresh handling
- push open từ background/terminated state
- notification center sync được với push-driven open flow

## 15. Thứ Tự Thực Thi Khuyến Nghị

1. dựng leaderboard models + API
2. rollout Home leaderboard widget
3. rollout Profile leaderboard snapshot
4. dựng leaderboard full page
5. dựng XP history page
6. dựng push permission service + token save flow
7. dựng foreground push handling
8. nối push tap vào shared notification action flow
9. verify cold start / background open / signed-out edge cases

Nếu làm ngược, team rất dễ có push permission và token sync nhưng user chạm push lại vào sai route hoặc không vào được learning flow đúng.

## 16. Done Checklist Cho Phase Này

- Home render được leaderboard widget bằng summary API
- Profile render được leaderboard snapshot
- leaderboard page support:
  - period filter
  - scope filter
  - my rank
  - top three
  - paginated ranking list
- XP history page render được summary stats + timeline
- push permission flow hoạt động đúng thời điểm
- FCM token được gửi lên backend sau khi enable push
- token refresh/re-register có chỗ xử lý
- foreground push có UI presentation phù hợp
- tap push từ background/terminated open đúng route
- push-driven session start vẫn giữ được launch context/re-entry semantics
- admin broadcast không làm gãy notification flow

## 17. Ranh Giới Sau Phase 5

Sau phase này, mobile sẽ có:

- daily retention loop
- recommendation orchestration
- weekly progress loop
- challenge/achievement
- social proof qua leaderboard
- device-level comeback loop qua push

Những gì còn lại sau phase 5 nếu tách tiếp sẽ nghiêng về:

- leaderboard nâng cao theo cohort/target band communities
- public profile / social layer
- AI recommendation nâng cao hơn
- campaign orchestration tinh vi hơn
- experiment/remote-config cho retention timing
- long-term progress storytelling và report history sâu hơn

## 18. Chốt Phạm Vi

Sau khi mobile đã hoàn tất phase 4, phase tiếp theo hợp lý nhất là khóa lớp `gamification visibility + push re-engagement`.

5 thứ phase 5 phải chốt:

1. leaderboard không chỉ là một page mà là social proof nhiều surface
2. XP history phải giải thích reward loop rõ ràng
3. push permission và token lifecycle phải được coi là app-level infrastructure
4. push tap phải đi qua cùng action resolver/re-entry spine từ phase 3
5. không tự invent analytics contract mới cho leaderboard nếu backend chưa chốt

Khi 5 thứ này đúng, mobile sẽ gần như bắt kịp toàn bộ lớp engagement đang hiện diện trên web và có nền tốt để bước sang các phase tối ưu hóa hoặc social/growth sâu hơn.
