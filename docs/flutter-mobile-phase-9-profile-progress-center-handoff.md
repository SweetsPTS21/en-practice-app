# Flutter Mobile Phase 9 Handoff

Tài liệu này mô tả phase tiếp theo sau `flutter-mobile-phase-8-ielts-assessment-review-handoff.md`.

Sau khi mobile đã hoàn tất phase 8, lớp lớn tiếp theo còn thiếu so với web không còn là một learning vertical nữa, mà là trung tâm hồ sơ và tiến độ cá nhân của user.

Kết luận hợp lý nhất cho phase 9 là:

- hoàn thiện profile summary ở app shell
- rollout full profile detail page
- cho phép edit thông tin, goals và avatar
- nối profile với recommendation, leaderboard, streak, vocabulary, progress data đã có từ các phase trước

Tên ngắn gọn nên dùng:

`Phase 9 - Profile, Goals, And Progress Center`

Nếu muốn tên kỹ thuật hơn:

`Phase 9 - Profile Summary, Full Profile Detail, Goal Editing, And Avatar Upload`

## 1. Kết Luận Sau Khi Đối Chiếu Kiến Trúc Hiện Tại

Sau khi rà soát web source và toàn bộ chuỗi docs mobile hiện có, có 6 kết luận chính.

### 1.1. Sau phase 8, mobile đã gần hoàn tất learning parity

Các lớp đã được cover theo roadmap hiện tại:

- base app foundation
- session/auth/router/action-resolver
- result journey, notification re-entry, push
- recommendation, flagship retention, weekly progress
- leaderboard và XP history
- vocabulary vertical
- writing/speaking/custom speaking
- IELTS

Khoảng trống lớn tiếp theo không còn là “thiếu module học”, mà là “thiếu nơi kể lại toàn bộ hành trình học của user”.

### 1.2. Web hiện có một profile system khá trưởng thành

Các điểm neo chính:

- `src/pages/profile/UserProfilePage.jsx`
- `src/components/profile/ProfileDropdownCard.jsx`
- `src/components/profile/EditProfileModal.jsx`
- `src/hooks/useUserProfileSummary.js`
- `src/hooks/useUserProfileDetail.js`
- `src/utils/profile.js`
- `src/api/profileApi.js`
- `docs/user-profile-fe.md`

Web hiện không chỉ có một trang “thông tin tài khoản”, mà đã có:

- dropdown profile summary ở header
- full profile page dạng progress center
- recommendation panel trong profile
- leaderboard snapshot trong profile
- recent activity
- skill/vocabulary/streak/goals sections
- edit modal
- avatar upload thật

### 1.3. `docs/user-profile-fe.md` không còn là source duy nhất

Doc profile cũ vẫn hữu ích cho shape response và intent sản phẩm, nhưng code web hiện tại đã tiến thêm một bước:

- `profileApi.uploadAvatar(file)` đã tồn tại
- `EditProfileModal.jsx` đang dùng `POST /files/avatar`
- flow edit thực tế có image crop + upload

Vì vậy, phase 9 cho mobile phải bám:

- doc profile cũ cho contract nền
- web code hiện tại cho behavior mới nhất

### 1.4. Profile hiện là “progress hub”, không chỉ là account page

Đối chiếu `UserProfilePage.jsx`, profile đang gom 5 lớp dữ liệu:

- identity: avatar, display name, bio
- goals: target band, exam date, daily goal, weekly word goal, preferred skill
- progress: level, XP, band progress, vocabulary progress, streak, heatmap
- retention/action: recommendations, recent activities
- social proof: leaderboard snapshot

Mobile không nên dựng phase 9 như một form account settings đơn giản.

### 1.5. Profile phase hợp lý hơn AI chat ở thời điểm này

AI chat realtime là cụm hợp lý cho phase sau, nhưng nếu ưu tiên nó trước profile thì mobile sẽ bị lệch:

- đã có rất nhiều learning/completion/recommendation data
- nhưng lại thiếu màn tổng hợp tiến độ cá nhân

Profile giúp kết nối toàn bộ những gì phase 2-8 đã build thành một “personal dashboard” có ý nghĩa.

### 1.6. Phase 9 nên khóa cả summary và detail, không tách quá nhỏ

Nếu chỉ làm full profile page mà bỏ summary dropdown:

- shell level parity vẫn lệch
- avatar/name/progress mini-card ở app chrome vẫn thiếu

Nếu chỉ làm summary mà chưa có detail/edit:

- value của profile vẫn chưa thành một destination thật

Vì vậy, phase 9 nên đi trọn:

- summary
- detail
- edit

## 2. Phase Này Là Gì

Nếu phase 8 là:

- assessment loop hoàn chỉnh cho IELTS

thì phase 9 là:

- nơi user nhìn thấy mình là ai
- đang tiến tới mục tiêu nào
- vừa tiến bộ ở đâu
- còn thiếu gì để chạm target

Sau phase này, mobile nên có profile loop hoàn chỉnh:

1. mở avatar/profile summary từ app shell
2. xem mini progress card
3. vào full profile center
4. xem progress, streak, goals, recommendation, leaderboard snapshot
5. chỉnh sửa profile và mục tiêu học
6. quay lại các learning surfaces từ profile recommendations

## 3. Source Of Truth Cần Bám

### 3.1. Mobile docs đã có

- `docs/mobile/flutter-mobile-base-handoff.md`
- `docs/mobile/flutter-mobile-phase-2-daily-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-4-recommendation-retention-report-handoff.md`
- `docs/mobile/flutter-mobile-phase-5-gamification-push-growth-handoff.md`
- `docs/mobile/flutter-mobile-phase-6-vocabulary-mastery-assessment-handoff.md`
- `docs/mobile/flutter-mobile-phase-7-productive-skills-speaking-writing-handoff.md`
- `docs/mobile/flutter-mobile-phase-8-ielts-assessment-review-handoff.md`

### 3.2. Docs contract chính cho phase này

- `docs/user-profile-fe.md`
- `docs/recommendation-flagship-api-fe-handoff.md`
- `docs/leaderboard-frontend.md`

### 3.3. Mã nguồn web cần coi là reference implementation

- `src/pages/profile/UserProfilePage.jsx`
- `src/components/profile/ProfileDropdownCard.jsx`
- `src/components/profile/EditProfileModal.jsx`
- `src/components/profile/page/ProfileHeroSection.jsx`
- `src/components/profile/page/ProfileMomentumSection.jsx`
- `src/components/profile/page/ProfileSkillsVocabularySection.jsx`
- `src/components/profile/page/ProfileConsistencyGoalsSection.jsx`
- `src/components/profile/page/ProfileRecommendationsPanel.jsx`
- `src/components/profile/page/ProfileLeaderboardSnapshot.jsx`
- `src/components/profile/page/ProfileRecentActivitySection.jsx`
- `src/hooks/useUserProfileSummary.js`
- `src/hooks/useUserProfileDetail.js`
- `src/utils/profile.js`
- `src/api/profileApi.js`

## 4. Vì Sao Phase 9 Phải Đi Sau Phase 8

Profile phase tận dụng trực tiếp dữ liệu và spine của các phase trước:

- phase 2: session, shell, routing
- phase 3: result journey/re-entry semantics
- phase 4: recommendation surfaces
- phase 5: leaderboard snapshot / XP semantics
- phase 6: vocabulary progress
- phase 7: productive skills progress
- phase 8: IELTS progress

Nếu làm profile sớm hơn:

- page vẫn render được
- nhưng phần progress center sẽ mỏng và thiếu meaning

Sau phase 8, profile mới đủ dữ liệu để trở thành “màn tổng hợp hành trình học” thật sự.

## 5. Mục Tiêu Của Phase

### 5.1. Product goal

Biến mobile từ app có nhiều learning flows thành app có một profile center rõ ràng, nơi user cảm nhận được tiến độ, mục tiêu và động lực của mình.

### 5.2. Technical goal

Dựng shared contracts cho:

- profile summary
- profile detail
- profile update
- avatar upload
- summary cache + detail cache
- query invalidation sau edit

### 5.3. UX goal

Sau phase này, user nên làm được:

1. mở profile summary từ header/app shell
2. thấy level, target band, streak, weekly XP
3. vào full profile page
4. xem goals, level progress, streak, skill progress, vocabulary progress
5. xem recommendation feed và leaderboard snapshot ngay trong profile
6. chỉnh sửa tên, bio, goals và avatar

## 6. In Scope

- header/profile summary card
- summary fetch strategy riêng
- full profile detail page
- profile header/hero
- compact stats / overview cards
- level & XP progress
- goals section
- today goal
- band progress / skills summary
- vocabulary summary
- streak + heatmap
- weak skills section nếu payload detail có
- recommendation feed trong profile
- recent activity section
- leaderboard snapshot trong profile
- edit profile modal/page
- avatar crop/upload flow
- cache refresh cho summary + detail + auth user display data

## 7. Out Of Scope

- public profile của user khác
- social graph, follow/friend
- achievement detail page riêng
- community/social profile feed
- AI chat
- settings page mở rộng ngoài những gì cần để support profile
- analytics enum mới nếu backend chưa chốt

## 8. Kiến Trúc Flutter Đề Xuất

```txt
lib/
  core/
    profile/
      profile_api.dart
      profile_models.dart
      profile_summary_models.dart
      profile_update_models.dart
      profile_avatar_upload_api.dart
      profile_formatters.dart
      profile_payload_normalizer.dart
  features/
    profile/
      application/
        profile_summary_controller.dart
        profile_detail_controller.dart
        profile_edit_controller.dart
      presentation/
        profile_page.dart
        profile_edit_sheet.dart
        widgets/
          profile_summary_card.dart
          profile_header_section.dart
          profile_hero_section.dart
          profile_compact_stats_grid.dart
          profile_momentum_section.dart
          profile_skills_vocabulary_section.dart
          profile_consistency_goals_section.dart
          profile_recommendations_panel.dart
          profile_leaderboard_snapshot.dart
          profile_recent_activity_section.dart
          profile_avatar_picker.dart
```

Nguyên tắc:

- summary và detail là hai data contracts riêng
- formatters/normailzers không để rải rác ở widget
- recommendation và leaderboard trong profile vẫn dùng chung domain với phase 4-5

## 9. Route Contract Đề Xuất

Mobile nên khóa route profile thành first-class destination:

- `/profile`
- `/profile?edit=1`

Nếu app shell có profile dropdown riêng hoặc bottom-sheet summary, vẫn nên coi `/profile` là canonical destination.

## 10. API Contract Cần Dùng

### 10.0. Response wrapper chung

Các endpoint profile hiện đi theo wrapper chuẩn của backend:

```json
{
  "success": true,
  "message": "OK",
  "data": {}
}
```

Mobile nên unwrap về DTO thật ở data layer, không để UI đọc trực tiếp wrapper.

Gợi ý model:

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T data;
}
```

### 10.1. Summary

- `GET /api/user/profile/summary`

Dùng cho:

- header dropdown
- mini profile card
- shell-level quick access

Response model gợi ý:

```dart
class UserProfileSummaryResponse {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final UserGoals goals;
  final LevelInfo levelInfo;
  final double? overallBand;
  final int? currentStreak;
  final int? weeklyXp;
}

class UserGoals {
  final double? targetIeltsBand;
  final String? targetExamDate;
  final int? dailyGoalMinutes;
  final int? weeklyWordGoal;
  final String? preferredSkill;
}

class LevelInfo {
  final int totalXp;
  final int currentLevel;
  final int currentLevelMinXp;
  final int nextLevel;
  final int nextLevelMinXp;
  final int xpIntoCurrentLevel;
  final int xpNeededForNextLevel;
  final double progressPercentage;
}
```

Response mẫu:

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "id": "5d7b7b86-8d85-4aa5-8d7c-32b542f2f881",
    "email": "learner@example.com",
    "displayName": "Alex Tran",
    "avatarUrl": "https://cdn.example.com/avatar/alex.png",
    "goals": {
      "targetIeltsBand": 7.0,
      "targetExamDate": "2026-09-30",
      "dailyGoalMinutes": 45,
      "weeklyWordGoal": 80,
      "preferredSkill": "SPEAKING"
    },
    "levelInfo": {
      "totalXp": 1280,
      "currentLevel": 5,
      "currentLevelMinXp": 1000,
      "nextLevel": 6,
      "nextLevelMinXp": 1500,
      "xpIntoCurrentLevel": 280,
      "xpNeededForNextLevel": 220,
      "progressPercentage": 56.0
    },
    "overallBand": 6.5,
    "currentStreak": 4,
    "weeklyXp": 135
  }
}
```

### 10.2. Detail

- `GET /api/user/profile`

Dùng cho:

- full profile page

Response model gợi ý:

```dart
class UserProfileResponse {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String createdAt;
  final String? lastLoginAt;
  final UserGoals goals;
  final LevelInfo levelInfo;
  final ProfileOverview overview;
  final ProfileStreak streak;
  final TodayGoal todayGoal;
  final BandProgress bandProgress;
  final VocabProgress vocabProgress;
  final DictionaryStats dictionaryStats;
  final List<String> weakSkills;
  final List<RecommendedPracticeItem> recommendedPractice;
  final List<RecentActivityItem> recentActivities;
  final LeaderboardSummary? leaderboardSummary;
}

class ProfileOverview {
  final int weeklyXp;
  final int totalLessonsCompleted;
  final int totalWordsLearned;
  final int totalStudyMinutes;
  final int wordsToReviewToday;
  final int currentStreak;
  final int longestStreak;
}

class ProfileStreak {
  final int currentStreak;
  final int longestStreak;
  final int activeDaysLast30;
  final List<StreakHeatmapDay> heatmap;
}

class StreakHeatmapDay {
  final String date;
  final bool hasActivity;
}

class TodayGoal {
  final int targetMinutes;
  final int studiedMinutes;
  final double percentage;
}

class BandMetric {
  final double? current;
  final double? previous;
}

class BandProgress {
  final BandMetric listening;
  final BandMetric reading;
  final BandMetric writing;
  final BandMetric speaking;
  final BandMetric overall;
}

class VocabProgress {
  final int totalWords;
  final int masteredWords;
  final int reviewingWords;
}

class DictionaryStats {
  final int totalWords;
  final int favoriteWords;
  final int wordsToReviewToday;
  final int newWords;
  final int learningWords;
  final int masteredWords;
}

class RecommendedPracticeItem {
  final String id;
  final String title;
  final String description;
  final String type;
  final String difficulty;
  final String estimatedTime;
  final String path;
  final String reason;
  final int? priority;
}

class RecentActivityItem {
  final String id;
  final String title;
  final String type;
  final String? score;
  final String? description;
  final String timestamp;
}

class LeaderboardSummary {
  final String period;
  final MyRankSummary? myRank;
  final List<LeaderboardUserSummary> topThree;
}

class MyRankSummary {
  final int rank;
  final int totalParticipants;
  final int xp;
  final int xpToNextRank;
  final int rankChange;
  final String rankChangeDirection;
}

class LeaderboardUserSummary {
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
```

Response mẫu rút gọn:

```json
{
  "success": true,
  "message": "OK",
  "data": {
    "id": "5d7b7b86-8d85-4aa5-8d7c-32b542f2f881",
    "email": "learner@example.com",
    "displayName": "Alex Tran",
    "avatarUrl": "https://cdn.example.com/avatar/alex.png",
    "bio": "Targeting IELTS 7.0 this year.",
    "createdAt": "2026-01-15 08:30:00",
    "lastLoginAt": "2026-04-04 09:10:00",
    "goals": {
      "targetIeltsBand": 7.0,
      "targetExamDate": "2026-09-30",
      "dailyGoalMinutes": 45,
      "weeklyWordGoal": 80,
      "preferredSkill": "SPEAKING"
    },
    "levelInfo": {
      "totalXp": 1280,
      "currentLevel": 5,
      "currentLevelMinXp": 1000,
      "nextLevel": 6,
      "nextLevelMinXp": 1500,
      "xpIntoCurrentLevel": 280,
      "xpNeededForNextLevel": 220,
      "progressPercentage": 56.0
    },
    "overview": {
      "weeklyXp": 135,
      "totalLessonsCompleted": 42,
      "totalWordsLearned": 380,
      "totalStudyMinutes": 1240,
      "wordsToReviewToday": 16,
      "currentStreak": 4,
      "longestStreak": 11
    },
    "streak": {
      "currentStreak": 4,
      "longestStreak": 11,
      "activeDaysLast30": 19,
      "heatmap": [
        { "date": "2026-04-01", "hasActivity": true },
        { "date": "2026-04-02", "hasActivity": false }
      ]
    },
    "todayGoal": {
      "targetMinutes": 45,
      "studiedMinutes": 28,
      "percentage": 62.2
    },
    "bandProgress": {
      "listening": { "current": 6.5, "previous": 6.0 },
      "reading": { "current": 6.5, "previous": 6.0 },
      "writing": { "current": 6.0, "previous": 5.5 },
      "speaking": { "current": 6.5, "previous": 6.0 },
      "overall": { "current": 6.5, "previous": 6.0 }
    },
    "vocabProgress": {
      "totalWords": 380,
      "masteredWords": 160,
      "reviewingWords": 95
    },
    "dictionaryStats": {
      "totalWords": 380,
      "favoriteWords": 28,
      "wordsToReviewToday": 16,
      "newWords": 34,
      "learningWords": 186,
      "masteredWords": 160
    },
    "weakSkills": ["WRITING_TASK_2", "MATCHING_HEADINGS"],
    "recommendedPractice": [],
    "recentActivities": [],
    "leaderboardSummary": {
      "period": "WEEKLY",
      "myRank": {
        "rank": 12,
        "totalParticipants": 240,
        "xp": 135,
        "xpToNextRank": 20,
        "rankChange": 3,
        "rankChangeDirection": "UP"
      },
      "topThree": []
    }
  }
}
```

### 10.3. Update

- `PUT /api/user/profile`

Dùng cho:

- edit modal/page

Request model:

```dart
class UpdateUserProfileRequest {
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final double? targetIeltsBand;
  final String? targetExamDate;
  final int? dailyGoalMinutes;
  final int? weeklyWordGoal;
  final String? preferredSkill;
}
```

Request mẫu:

```json
{
  "displayName": "Alex Tran",
  "avatarUrl": "https://cdn.example.com/avatar/alex.png",
  "bio": "Targeting IELTS 7.0 this year.",
  "targetIeltsBand": 7.0,
  "targetExamDate": "2026-09-30",
  "dailyGoalMinutes": 45,
  "weeklyWordGoal": 80,
  "preferredSkill": "SPEAKING"
}
```

Validation semantics mobile nên bám:

- `displayName`: 1-100 chars
- `avatarUrl`: <= 500 chars
- `bio`: <= 500 chars
- `targetIeltsBand`: 0.0 -> 9.0
- `dailyGoalMinutes`: 1 -> 1440
- `weeklyWordGoal`: 1 -> 10000
- `preferredSkill`: machine value, không gửi label hiển thị

Response:

- backend có thể trả wrapper `success/message/data`
- mobile nên coi update thành công là trigger để refetch summary + detail thay vì phụ thuộc tuyệt đối vào response body sau mutation

### 10.4. Avatar upload

Theo web code hiện tại:

- `POST /api/files/avatar`

Điểm này quan trọng vì doc profile cũ chưa phản ánh behavior mới nhất, nhưng source code hiện tại đã dùng upload thật.

Request:

- `multipart/form-data`
- field: `file`

Response model gợi ý:

```dart
class UploadAvatarResponse {
  final String avatarUrl;
}
```

Response mẫu:

```json
{
  "success": true,
  "message": "Avatar uploaded",
  "data": {
    "avatarUrl": "https://cdn.example.com/avatar/alex.png"
  }
}
```

Mapping rule:

1. upload file
2. lấy `avatarUrl` từ response
3. set vào form state
4. submit `PUT /api/user/profile`

### 10.5. Recommendation feed trong profile

Vì profile page web đang nhúng recommendation panel riêng, mobile phase này cũng nên map rõ model response cho surface `PROFILE`.

Endpoint:

- `GET /api/user/recommendations/feed?surface=PROFILE`

Response model gợi ý:

```dart
class RecommendationFeedResponse {
  final String generatedAt;
  final RecommendationCardModel? primary;
  final List<RecommendationCardModel> items;
}

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
  final String? freshUntil;
  final RecommendationExplanation? explanation;
  final String? referenceType;
  final String? referenceId;
  final Map<String, dynamic> metadata;
}

class RecommendationExplanation {
  final String? message;
  final String? shortReason;
}
```

Mobile có thể reuse DTO phase 4 nếu đã tồn tại, nhưng trong profile page nên map rõ ràng từ data layer chứ không parse ad-hoc ở widget.

## 11. Data Strategy Mobile Phải Giữ

### 11.1. Summary và detail phải fetch tách biệt

Giữ đúng semantics web:

- summary nhẹ, load sớm hoặc khi user mở menu
- detail chỉ fetch khi user vào profile page

Không nên:

- fetch full profile ngay sau login chỉ để render avatar menu

### 11.2. Mutation phải invalidate nhiều nguồn

Sau khi update thành công:

- refresh profile summary
- refresh profile detail
- refresh auth user display name/avatar nếu app shell đang giữ riêng

### 11.3. Không lấy cached auth user làm source of truth cuối cùng

Auth session chỉ nên dùng cho shell bootstrap. Profile summary/detail mới là nguồn dữ liệu đúng cho progress center.

## 12. Các Surface Mobile Cần Có

### 12.1. Profile Summary Card

Mục tiêu:

- hiển thị nhanh identity + motivation signals

Thông tin nên có:

- avatar
- display name
- email
- level
- target band
- current streak
- weekly XP
- progress tới level tiếp theo

CTA:

- view profile
- edit profile
- settings nếu app shell đang cần

### 12.2. Full Profile Page

Mục tiêu:

- progress center của user

Sections nên bám web:

- profile header
- hero section
- compact stats
- momentum / weekly data
- skills + vocabulary
- consistency + goals
- recommendations
- leaderboard snapshot
- recent activities

### 12.3. Edit Profile Flow

Mục tiêu:

- chỉnh identity và learning goals

Fields nên support:

- displayName
- bio
- targetIeltsBand
- targetExamDate
- dailyGoalMinutes
- weeklyWordGoal
- preferredSkill
- avatarUrl qua upload flow

## 13. Formatting / Normalization Rules

Mobile nên mirror logic trong `src/utils/profile.js`:

- `formatBand`
- `formatXp`
- `formatMinutes`
- `formatDateTime`
- `normalizeProfilePayload`

Các rule quan trọng:

- band score format 1 decimal
- minutes cần format human-readable
- payload update phải normalize empty string về `null` khi phù hợp
- preferred skill dùng enum/value machine-readable, không lưu label hiển thị

## 14. Avatar Upload Rules

Theo web code hiện tại:

- chỉ nhận image files
- giới hạn tối đa 5 MB
- upload xong lấy `avatarUrl`
- set lại form field rồi submit profile update

Mobile phase 9 nên giữ cùng semantics:

- validate file/image trước khi upload
- cho crop cơ bản nếu stack cho phép
- avatar upload là bước phụ trợ cho profile update, không phải flow tách rời

## 15. Tích Hợp Với Spine Phase 4-5

### 15.1. Recommendation feed trong profile

Profile phase không tự tạo recommendation domain mới.

Nó phải reuse:

- `GET /api/user/recommendations/feed?surface=PROFILE`
- recommendation card behavior
- feedback flow nếu mobile đã có shared component từ phase 4

### 15.2. Leaderboard snapshot trong profile

Profile phase không fetch leaderboard full chỉ để render snapshot nếu summary/detail payload đã đủ.

Nếu payload detail đã có `leaderboardSummary`, nên ưu tiên dùng trực tiếp như web.

## 16. Delivery Slices Đề Xuất

### Slice A. Summary foundation

- summary API
- profile summary card/dropdown
- summary cache strategy

### Slice B. Full profile page

- detail API
- header/hero
- stats/momentum
- skills/vocabulary
- consistency/goals

### Slice C. Retention surfaces inside profile

- recommendation panel
- leaderboard snapshot
- recent activity

### Slice D. Edit flow

- edit modal/page
- payload normalization
- update mutation
- summary/detail invalidation

### Slice E. Avatar upload

- image picking
- upload endpoint
- crop/preview
- integrate with edit form

## 17. Definition Of Done

Phase 9 được coi là hoàn thành khi:

1. app shell có profile summary usable
2. `/profile` render full detail page end-to-end
3. user thấy được level, XP, goals, streak, skills, vocabulary progress
4. recommendation feed trong profile hoạt động đúng semantics
5. leaderboard snapshot trong profile hoạt động đúng semantics
6. user có thể edit profile và goals
7. avatar upload hoạt động end-to-end
8. update xong thì summary, detail và shell-level display data đều refresh đúng

## 18. Rủi Ro Cần Chốt Sớm

### 18.1. Doc profile cũ và code mới có lệch nhẹ

Điểm lệch chính là avatar upload. Phase 9 phải bám code hiện tại làm source of truth cuối cùng.

### 18.2. Widget count của profile khá nhiều

Không nên coi profile là một page đơn giản. Cần cắt slice delivery rõ để tránh biến phase này thành “UI polish vô tận”.

### 18.3. Query invalidation dễ bị thiếu

Nếu update profile xong mà shell-level avatar/displayName không refresh, UX sẽ gãy. Đây là integration risk lớn nhất của phase 9.

## 19. Tại Sao Chưa Ưu Tiên AI Chat

AI chat realtime vẫn là cụm tiếp theo hợp lý, nhưng nên đứng sau profile vì:

- profile là nơi gom toàn bộ value của các phase 2-8
- AI chat là một feature mới mang tính assistant/tool
- thiếu AI chat không làm lệch perceived progress bằng thiếu profile center

## 20. Kết Luận

Sau khi mobile đã hoàn tất phase 8, phase tiếp theo hợp lý nhất là:

`Profile, Goals, And Progress Center`

Đây là phase giúp mobile đi từ:

- app đã có gần đủ learning flows

thành:

- app có một trung tâm tiến độ cá nhân hoàn chỉnh, nơi user thấy rõ danh tính học tập, mục tiêu và đà tiến bộ của mình.

Nếu cần chốt thứ tự sau phase 9, nên đi:

1. AI chat realtime / learning assistant
2. legacy cleanup và flow consolidation
3. polish, instrumentation và parity gaps nhỏ còn lại
