# Flutter Mobile Phase 4 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`.

Nếu phase 3 đã khóa được:

- result journey
- reminder/banner
- notification re-entry loop

thì phase 4 là lớp giúp mobile chuyển từ `biết kéo user quay lại` sang `biết điều phối user nên học gì tiếp theo và kể lại tiến bộ theo chu kỳ tuần`.

Trọng tâm của phase này là:

- recommendation surfaces
- flagship retention block trên Home
- weekly report
- weekly challenge
- achievements

## 1. Kết Luận Kiến Trúc Sau Khi Đối Chiếu Web Hiện Tại

Sau khi rà soát code web hiện tại, có 6 kết luận quan trọng cho phase tiếp theo.

### 1.1. Recommendation trên web đã là một lớp dùng chung thật, không còn là widget đơn lẻ

Các điểm bám chính:

- `src/features/recommendation/RecommendationCard.jsx`
- `src/features/recommendation/RecommendationSurfaceSlot.jsx`
- `src/api/recommendationApi.js`

Recommendation hiện không chỉ xuất hiện ở một nơi. Web đang gắn recommendation vào nhiều surface với cùng semantics:

- `HOME`
- `PROFILE`
- `RESULT`
- `NOTIFICATION`
- `WEEKLY_REPORT`

Mobile không nên implement recommendation riêng lẻ theo từng page. Nó cần một shared component + shared feedback flow ngay từ đầu.

### 1.2. Recommendation click trên web đi qua feedback endpoint trước khi điều hướng

`RecommendationCard.jsx` hiện đang:

1. gọi `POST /user/recommendations/{recommendationKey}/feedback` với action `CLICK`
2. sau đó mới điều hướng
3. nếu dismiss/snooze thì cũng đi qua cùng feedback endpoint

Kết luận:

- mobile phase 4 không nên coi recommendation là card chỉ để navigate
- feedback là một phần của contract, không phải enhancement tùy chọn

### 1.3. Flagship retention không phải là recommendation feed thông thường

`FlagshipRetentionPanel.jsx` cho thấy Home đang có một block riêng với 3 trụ:

- daily speaking prompt
- vocab micro-learning
- weekly challenge progress

Block này khác recommendation ở 3 điểm:

- payload khác
- semantics analytics khác
- một số item có special launch metadata riêng như `SPEAKING_PROMPT` và `VOCAB_MICRO_SESSION`

Vì vậy mobile nên model flagship retention như một feature riêng, không nhét chung vào recommendation feed.

### 1.4. Weekly report và challenge là hai màn riêng nhưng liên kết rất chặt

Web hiện có:

- `src/pages/reports/WeeklyReportPage.jsx`
- `src/pages/challenges/WeeklyChallengePage.jsx`
- `src/api/weeklyReportApi.js`
- `src/api/challengeApi.js`
- `src/api/achievementApi.js`

Mối quan hệ hiện tại:

- weekly report có `challengeSummary`
- weekly report có thể chứa `recommendation`
- challenge page lại đọc thêm weekly report để lấy `nextStep`
- challenge page đồng thời đọc achievements

Kết luận:

- mobile không nên dựng weekly report, challenge và achievements như 3 feature hoàn toàn tách rời
- chúng phải được rollout theo cùng một phase vì dữ liệu đang nối nhau trực tiếp

### 1.5. Profile đã có recommendation feed riêng trên web

`ProfileRecommendationsPanel.jsx` hiện dùng:

- `recommendationApi.getFeed('PROFILE')`

Điều này cho thấy recommendation không chỉ là Home concern.

Nếu mobile phase 4 chỉ dựng Home recommendation mà bỏ qua profile feed, kiến trúc sẽ bị lệch so với web hiện tại.

### 1.6. Phase 3 foundation sẽ được tái sử dụng nguyên vẹn

Recommendation và flagship retention trên web vẫn dựa vào:

- `learningAction`
- `rememberLearningLaunch`
- `learningAnalytics`

Nói cách khác, phase 4 không thay mental model phase 3. Nó chỉ gắn thêm nhiều source entry hơn vào cùng launch/context/analytics spine đã có.

## 2. Phase Này Là Gì

Nếu phase 3 là:

- học xong có recap
- app biết kéo user quay lại

thì phase 4 là:

- app biết đề xuất hành động tiếp theo theo ngữ cảnh
- app có 1 vài flagship loops đủ mạnh để tạo thói quen
- app kể lại tiến bộ theo tuần
- app biến challenge và achievement thành lớp động lực có cấu trúc

Tên ngắn gọn nên dùng:

`Phase 4 - Recommendation, Flagship Retention, And Weekly Progress`

Nếu muốn tên kỹ thuật hơn:

`Phase 4 - Recommendation Surfaces, Flagship Loops, Weekly Report, Challenge, And Achievement`

## 3. Source Of Truth Cần Bám

### 3.1. Mobile docs đã có

- `docs/mobile/flutter-mobile-base-handoff.md`
- `docs/mobile/flutter-mobile-phase-2-daily-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`

### 3.2. Docs contract chính cho phase này

- `docs/recommendation-flagship-api-fe-handoff.md`
- `docs/result-journey-reminder-api-fe-handoff.md`
- `docs/home-launchpad-api-fe-handoff.md`

### 3.3. Mã nguồn web cần coi là reference implementation

- `src/features/recommendation/RecommendationCard.jsx`
- `src/features/recommendation/RecommendationSurfaceSlot.jsx`
- `src/features/recommendation/FlagshipRetentionPanel.jsx`
- `src/components/profile/page/ProfileRecommendationsPanel.jsx`
- `src/pages/dashboard/HomePage.jsx`
- `src/pages/reports/WeeklyReportPage.jsx`
- `src/pages/challenges/WeeklyChallengePage.jsx`
- `src/api/recommendationApi.js`
- `src/api/dashboardApi.js`
- `src/api/weeklyReportApi.js`
- `src/api/challengeApi.js`
- `src/api/achievementApi.js`
- `src/features/learning/learningAnalytics.js`
- `src/features/learning/learningAction.js`

## 4. Vì Sao Phase Này Phải Đi Sau Phase 3

Phase 3 đã cho mobile:

- shared action resolver
- result CTA flow
- reminder/banner re-entry
- notification action flow
- launch context và started tracking

Phase 4 dựa trực tiếp lên các lớp này.

Nếu làm phase 4 trước khi phase 3 ổn, mobile sẽ gặp 3 vấn đề:

- recommendation click không giữ được launch context nhất quán
- flagship retention click không bắn analytics started/completed đúng semantics
- weekly report/challenge chỉ là màn xem số liệu, chưa nối được về các learning actions thực tế

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app có nhiều entry points thành app có một lớp điều phối thông minh và có nhịp tuần rõ ràng.

### 5.2. Technical goal

Dựng shared contracts cho:

- recommendation surfaces
- recommendation feedback
- flagship retention block
- weekly report payload
- weekly challenge payload
- achievements list

### 5.3. UX goal

Sau phase này, user nên làm được luồng sau:

1. mở Home hoặc Profile và thấy gợi ý học tiếp phù hợp
2. dismiss hoặc snooze gợi ý nếu chưa muốn học
3. mở weekly report để xem tóm tắt tiến bộ
4. đi sang challenge page để theo dõi tiến độ tuần
5. nhìn thấy achievements đã mở khóa và động lực tiếp theo

## 6. In Scope

- recommendation primary/feed
- feedback action `CLICK | DISMISS | SNOOZE`
- recommendation surfaces cho:
    - Home
    - Profile
    - Result
    - Notification
    - Weekly Report
- flagship retention block trên Home
- daily speaking prompt launch flow
- vocab micro-learning launch flow
- weekly report latest page
- weekly challenge current page
- achievements list/grid
- analytics cho recommendation và flagship loops

## 7. Out Of Scope

- recommendation model training hoặc AI ranking phức tạp ở client
- multi-week weekly report history
- challenge claim/reward manual flow
- achievement detail pages riêng
- social leaderboard expansion mới
- campaign orchestration hoặc experiment framework cho recommendation

## 8. Kiến Trúc Flutter Đề Xuất Cho Phase Này

```txt
lib/
  core/
    recommendation/
      recommendation_api.dart
      recommendation_models.dart
      recommendation_feedback_models.dart
      recommendation_route_bridge.dart
      recommendation_surface.dart
    retention/
      flagship_retention_api.dart
      flagship_retention_models.dart
      weekly_report_api.dart
      weekly_report_models.dart
      weekly_challenge_api.dart
      weekly_challenge_models.dart
      achievement_api.dart
      achievement_models.dart
  features/
    recommendation/
      presentation/
        widgets/
          recommendation_card.dart
          recommendation_surface_slot.dart
          recommendation_feed_section.dart
      application/
        recommendation_controller.dart
        recommendation_feedback_controller.dart
    home/
      presentation/
        widgets/
          flagship_retention_panel.dart
          daily_speaking_prompt_tile.dart
          vocab_micro_learning_tile.dart
          weekly_challenge_tile.dart
    reports/
      presentation/
        weekly_report_page.dart
        widgets/
          weekly_report_summary_card.dart
          weekly_report_insight_card.dart
    challenges/
      presentation/
        weekly_challenge_page.dart
        widgets/
          challenge_progress_card.dart
          achievement_grid.dart
          achievement_card.dart
```

Điểm quan trọng:

- `recommendation` và `flagship retention` là hai nhóm model khác nhau
- `weekly report`, `challenge`, `achievement` có thể khác page nhưng nên dùng chung một retention domain

## 9. Recommendation Contract

## 9.1. Endpoints

```txt
GET /api/user/recommendations/primary
GET /api/user/recommendations/feed
POST /api/user/recommendations/{recommendationKey}/feedback
```

### 9.1.1. Surfaces cần support

```txt
HOME
PROFILE
RESULT
NOTIFICATION
WEEKLY_REPORT
```

## 9.2. Model gợi ý

```dart
class RecommendationCardModel {
  final String recommendationKey;
  final String type;
  final String title;
  final String description;
  final String actionUrl;
  final String? difficulty;
  final int? estimatedMinutes;
  final int? urgencyScore;
  final int? confidenceGainScore;
  final int? priority;
  final DateTime? freshUntil;
  final RecommendationExplanation? explanation;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;
}

class RecommendationFeed {
  final DateTime generatedAt;
  final RecommendationCardModel? primary;
  final List<RecommendationCardModel> items;
}
```

## 9.3. Feedback contract

```dart
enum RecommendationFeedbackAction {
  click,
  dismiss,
  snooze,
}

class RecommendationFeedbackRequest {
  final RecommendationFeedbackAction action;
  final String sourceSurface;
  final DateTime? snoozeUntil;
  final String? route;
  final Map<String, dynamic>? metadata;
}
```

## 9.4. Behavior rules

- khi user bấm recommendation: ưu tiên gửi feedback `CLICK` trước rồi mới navigate
- khi user dismiss: gửi `DISMISS`
- khi user snooze: gửi `SNOOZE` kèm `snoozeUntil`
- nếu feedback request fail:
    - không nên optimistic remove card vĩnh viễn
    - nên báo lỗi nhẹ hoặc giữ card lại

## 9.5. Rendering rules

Mobile nên render trực tiếp từ:

- `title`
- `description`
- `estimatedMinutes`
- `explanation.message`

Không nên tự suy diễn:

- CTA text từ `type`
- copy giải thích từ `reasonCode`
- route từ `referenceId`

## 9.6. Điều hướng recommendation vẫn phải dùng phase 3 foundation

Recommendation click vẫn phải đi qua:

1. shared route normalization/fallback
2. learning launch store nếu target là session route
3. analytics/feedback
4. navigate

## 10. Flagship Retention Contract

## 10.1. Endpoint

```txt
GET /api/user/dashboard/flagship-retention
```

## 10.2. Block structure

```dart
class FlagshipRetention {
  final DailySpeakingPrompt? dailySpeakingPrompt;
  final VocabMicroLearning? vocabMicroLearning;
  final WeeklyChallenge? weeklyChallenge;
}
```

## 10.3. Daily speaking prompt

Mobile cần đọc:

- `promptId`
- `topic`
- `prompt`
- `persona`
- `difficulty`
- `actionUrl`
- `estimatedMinutes`
- `reason`
- `resumeState`

`resumeState` là hint để đổi CTA copy:

- `START`
- `RESUME`

## 10.4. Vocab micro-learning

Mobile cần đọc:

- `title`
- `description`
- `estimatedMinutes`
- `targetWordCount`
- `dueWordCount`
- `actionUrl`
- `reason`
- `words`

`words` đủ để render preview card, không cần call thêm API chỉ để hiện chip preview.

## 10.5. Weekly challenge preview trong flagship block

Block challenge ở flagship retention không thay thế challenge page full.

Nó chỉ là preview gồm:

- title
- description
- progress
- rewardXp
- CTA mở `/challenges`

## 10.6. Special launch semantics cần giữ từ web

Web hiện đang gắn special launch metadata:

- `SPEAKING_PROMPT`
- `VOCAB_MICRO_SESSION`

Mobile phase 4 phải giữ đúng semantics này để analytics started/completed khớp:

- `SPEAKING_PROMPT_STARTED`
- `SPEAKING_PROMPT_COMPLETED`
- `VOCAB_MICRO_SESSION_STARTED`
- `VOCAB_MICRO_SESSION_COMPLETED`

## 11. Weekly Report Contract

## 11.1. Endpoint

```txt
GET /api/user/reports/weekly/latest
```

## 11.2. Model gợi ý

```dart
class WeeklyReport {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int studyMinutes;
  final int vocabularyLearned;
  final int testsCompleted;
  final double? bandImprovement;
  final String? strongestWin;
  final String? repeatedWeakness;
  final String? nextStep;
  final WeeklyChallengeSummary? challengeSummary;
  final RecommendationCardModel? recommendation;
}
```

## 11.3. Quan sát rollout thực tế trên web

Weekly report page hiện:

- render summary metrics
- render strongest win / repeated weakness / next step
- render challenge summary card
- render recommendation embedded trong report payload

Điểm này quan trọng:

- weekly report recommendation hiện không nhất thiết fetch bằng `recommendationApi.getPrimary('WEEKLY_REPORT')`
- web đang dùng `report.recommendation` trực tiếp từ payload weekly report

Mobile nên bám semantics này để tránh gọi API thừa nếu payload report đã đủ.

## 11.4. Rendering rule

- `bandImprovement == null` thì render neutral state, không ép `+0.0`
- `nextStep` là plain text, không phải route
- `challengeSummary` là summary, CTA sâu nên dẫn sang challenge page

## 12. Weekly Challenge Và Achievement Contract

## 12.1. Endpoints

```txt
GET /api/user/challenges/weekly/current
GET /api/user/achievements
```

## 12.2. Weekly challenge model

```dart
class WeeklyChallenge {
  final String definitionId;
  final String code;
  final String title;
  final String description;
  final int currentValue;
  final int targetValue;
  final int rewardXp;
  final bool completed;
  final DateTime weekStart;
  final DateTime weekEnd;
}
```

## 12.3. Achievement model

```dart
class Achievement {
  final String definitionId;
  final String code;
  final String title;
  final String description;
  final String? icon;
  final bool unlocked;
  final DateTime? unlockedAt;
}
```

## 12.4. Sorting rule

Nên giữ đúng tinh thần web:

1. unlocked trước
2. unlockedAt mới hơn trước
3. fallback theo title/code

## 12.5. Ghi chú quan trọng

- backend đã auto-credit reward khi challenge complete
- mobile không cần claim endpoint
- nếu challenge `completed = true`, CTA có thể chuyển sang weekly report hoặc review state

## 13. Shared Navigation Và Launch Context Trong Phase 4

Phase 4 vẫn dùng toàn bộ spine từ phase 3.

## 13.1. Recommendation click

Nếu target cuối cùng là session route:

- remember launch context
- gắn source surface tương ứng
- điều hướng sau khi feedback `CLICK` thành công

## 13.2. Flagship retention click

Nếu là:

- daily speaking prompt
- vocab micro-learning

thì ngoài launch context chung còn cần giữ metadata đặc biệt:

- `resumeState`
- `targetWordCount`
- `specialEvent`

## 13.3. Weekly report và challenge page

Hai màn này chủ yếu là read/reflect surfaces, nhưng recommendation card bên trong vẫn có thể dẫn vào learning session nên vẫn phải dùng chung resolver.

## 14. Analytics Contract Cho Phase Này

## 14.1. Backend/web đang auto-log, mobile không nên bắn lại

```txt
RECOMMENDATION_SERVED
SPEAKING_PROMPT_SERVED
VOCAB_MICRO_SESSION_SERVED
WEEKLY_CHALLENGE_PROGRESS_UPDATED
WEEKLY_CHALLENGE_COMPLETED
ACHIEVEMENT_UNLOCKED
```

## 14.2. Mobile cần bắn

```txt
RECOMMENDATION_CLICKED
RECOMMENDATION_COMPLETED
SPEAKING_PROMPT_STARTED
SPEAKING_PROMPT_COMPLETED
VOCAB_MICRO_SESSION_STARTED
VOCAB_MICRO_SESSION_COMPLETED
NOTIFICATION_OPENED
NOTIFICATION_CLICKED
```

## 14.3. Quy tắc tracking quan trọng

- với recommendation click, ưu tiên feedback endpoint hơn là analytics event rời
- dismiss/snooze bắt buộc đi qua feedback endpoint
- speaking/vocab started-completed vẫn phải bám launch context, không bắn event chỉ vì card được mở

## 15. Màn Hình Nên Có Ở Cuối Phase

### 15.1. Bắt buộc

- Home recommendation primary
- Home flagship retention block
- Profile recommendation feed
- Result recommendation slot
- Notification recommendation slot
- Weekly report page
- Weekly challenge page
- Achievement grid/list trong challenge page

### 15.2. Có thể gộp rollout nếu nguồn lực hạn chế

Gói A:

- recommendation card + feedback flow
- Home primary + Profile feed + Result slot

Gói B:

- flagship retention block
- speaking/vocab special event handling

Gói C:

- weekly report
- weekly challenge
- achievements

## 16. Thứ Tự Thực Thi Khuyến Nghị

1. dựng shared recommendation models + feedback models
2. dựng shared recommendation card widget
3. nối feedback `CLICK | DISMISS | SNOOZE`
4. rollout recommendation ở Home primary
5. rollout recommendation feed ở Profile
6. rollout recommendation slot ở Result và Notification
7. dựng flagship retention block trên Home
8. nối special launch semantics cho speaking prompt và vocab micro session
9. dựng weekly report page
10. dựng challenge page + achievements

Nếu làm ngược, team sẽ rất dễ có weekly report/challenge UI nhưng thiếu shared recommendation/retention behavior phía dưới.

## 17. Done Checklist Cho Phase Này

- có shared recommendation card/widget dùng được cho nhiều surface
- recommendation click gọi feedback trước khi navigate
- dismiss và snooze gọi đúng feedback endpoint
- Home render được primary recommendation
- Profile render được recommendation feed
- Result render được recommendation surface slot
- Notification page render được recommendation surface slot
- Home render được flagship retention block
- daily speaking prompt giữ được special launch metadata
- vocab micro session giữ được targetWordCount và launch metadata
- weekly report render được:
    - summary metrics
    - insights
    - challenge summary
    - embedded recommendation
- challenge page render được current challenge
- challenge page render được achievements đúng sort order
- analytics không double-log các event served do backend đã tự log

## 18. Ranh Giới Sau Phase 4

Sau phase này, mobile sẽ có gần như đầy đủ retention product layer đang thấy ở web:

- recommendation
- flagship daily loops
- weekly progress
- challenge
- achievements

Những gì còn lại sau phase 4 nếu cần tách tiếp sẽ nghiêng về:

- tối ưu hóa UX/polish
- mở rộng weekly report history
- experiment/snooze tuning
- social/gamification sâu hơn
- campaign orchestration đa điểm chạm

## 19. Chốt Phạm Vi

Sau khi mobile đã hoàn tất phase 3, bước tiếp theo hợp lý nhất là khóa lớp `recommendation + flagship retention + weekly progress`.

5 thứ phase 4 phải chốt:

1. recommendation là shared contract nhiều surface
2. feedback là một phần của recommendation flow, không phải optional
3. flagship retention là feature riêng, không phải recommendation feed biến thể
4. weekly report và challenge phải được rollout cùng nhau
5. achievement là phần mở rộng tự nhiên của challenge, không nên tách thành phase rời quá sớm

Khi 5 thứ này đúng, mobile sẽ gần như bắt kịp lớp retention/product orchestration hiện tại của web mà không phải refactor lại spine từ phase 3.
