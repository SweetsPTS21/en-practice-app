# Flutter Mobile Firebase Migration Handoff

Tài liệu này chốt phần migrate Firebase cho mobile Flutter với hai mục tiêu thực dụng:

- notification permission, nhận push, foreground/background open flow phải giữ cùng semantics với web
- team có đủ thông tin và checklist để đưa build Android/iOS lên Firebase App Distribution

Tài liệu này không thay thế `flutter-mobile-phase-3-result-journey-notification-loop-handoff.md` hay `flutter-mobile-phase-5-gamification-push-growth-handoff.md`. Nó là lớp delivery chi tiết cho Firebase setup và release plumbing.

## 1. Mục tiêu migration

Sau migration này, mobile cần đạt được:

1. dùng cùng Firebase project với web để không tách rời notification infrastructure
2. xin quyền push đúng thời điểm, không xin mù quáng khi cold start
3. lấy và đồng bộ FCM token lên backend sau khi user signed-in và đã grant permission
4. foreground push, background tap, terminated open đều đi qua cùng action resolver/re-entry spine
5. Android và iOS đều có đường upload build rõ ràng lên Firebase App Distribution

## 2. Source of truth cần bám

### 2.1. Code web hiện tại

- `src/App.jsx`
- `src/utils/notificationHelper.js`
- `src/firebase.js`
- `public/firebase-messaging-sw.js`
- `src/api/authApi.js`
- `docs/notification-fe.md`
- `docs/mobile/flutter-mobile-phase-3-result-journey-notification-loop-handoff.md`
- `docs/mobile/flutter-mobile-phase-5-gamification-push-growth-handoff.md`

### 2.2. Tài liệu chính thức cần đối chiếu khi setup

- Firebase Flutter setup: <https://firebase.google.com/docs/flutter/setup>
- Firebase Cloud Messaging cho Flutter: <https://firebase.google.com/docs/cloud-messaging/flutter/get-started>
- Firebase App Distribution Android CLI: <https://firebase.google.com/docs/app-distribution/android/distribute-cli>
- Firebase App Distribution Android Gradle: <https://firebase.google.com/docs/app-distribution/android/distribute-gradle>
- Firebase App Distribution iOS CLI: <https://firebase.google.com/docs/app-distribution/ios/distribute-cli>
- Firebase App Distribution iOS fastlane: <https://firebase.google.com/docs/app-distribution/ios/distribute-fastlane>
- Android 13 notification permission: <https://developer.android.com/guide/topics/ui/notifiers/notification-permission>
- Apple remote notification background mode: <https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app>

## 3. Semantics mobile phải giữ giống web

Từ `src/App.jsx` và `src/utils/notificationHelper.js`, hành vi hiện tại của web là:

1. chỉ xử lý push khi user đã authenticated
2. nếu quyền notification đã `granted`, lấy FCM token và gửi token lên backend ngay
3. nếu quyền đang `default`, hiện prompt mềm trong app trước, sau đó mới gọi system permission
4. foreground push không route thẳng kiểu thô; nó mở notice/toast trước
5. khi user chạm notification/toast, app resolve `actionUrl` rồi fallback theo metadata/reference
6. nếu action dẫn vào learning session, app phải nhớ launch context để giữ analytics và re-entry semantics

Mobile phải giữ đúng logic này. Không nên biến push mobile thành một flow riêng tách khỏi notification/action infrastructure đã có ở web.

## 4. Kết luận kiến trúc

### 4.1. Nên dùng cùng Firebase project với web

Lý do:

- admin/broadcast và notification backend đang đã bám cùng một project vận hành
- App Distribution cũng nằm luôn trong cùng console, giúp QA theo dõi Android, iOS và web config cùng chỗ
- tránh tách riêng project mobile rồi phải đồng bộ token, environment và tester groups thủ công

### 4.2. Nên tách 2 lớp rõ ràng

1. runtime Firebase integration
   - `firebase_core`
   - `firebase_messaging`
   - optional `flutter_local_notifications`

2. release/distribution tooling
   - Firebase CLI cho Android và iOS
   - hoặc Gradle plugin cho Android, fastlane cho iOS nếu team đã có CI native

Không cần thêm runtime plugin chỉ để upload App Distribution.

### 4.3. Khuyến nghị đường đi ít ma sát nhất

- runtime: FlutterFire CLI + `firebase_core` + `firebase_messaging`
- distribution local/CI: Firebase CLI

Lý do:

- ít lệ thuộc platform-specific automation hơn
- Android và iOS dùng cùng một command family
- tài liệu nội bộ ngắn hơn, onboarding dễ hơn

Gradle plugin và fastlane chỉ nên dùng khi team đã có pipeline native riêng.

## 5. Setup Firebase nền cho Flutter

## 5.1. Tạo app Android và iOS trong Firebase project

Phải đăng ký đủ:

- Android app với đúng `applicationId`
- iOS app với đúng `bundle identifier`

Không được để lệch casing hoặc đổi package/bundle sau khi đã chốt App Distribution và push.

## 5.2. Dùng FlutterFire CLI để tạo config

Từ root dự án Flutter:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Sau bước này, dự án mobile nên có:

- `lib/firebase_options.dart`
- app Android và iOS đã được map vào đúng Firebase project

## 5.3. Initialize Firebase sớm ở app bootstrap

Packages tối thiểu:

```bash
flutter pub add firebase_core
flutter pub add firebase_messaging
```

Khởi tạo trong `main.dart`:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Firebase init phải hoàn tất trước khi bootstrap auth session, vì push lifecycle phụ thuộc vào auth state.

## 6. Android setup bắt buộc

## 6.1. Config app

Android app cần có:

- đúng `applicationId`
- `google-services.json` tương ứng environment
- Google Services plugin được apply đúng

Nếu team dùng flavor như `dev`, `staging`, `prod`, mỗi flavor cần map rõ về Firebase app nào.

## 6.2. Notification permission

Từ Android 13 trở lên, phải khai báo:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Ngoài khai báo manifest, app còn phải request runtime permission đúng ngữ cảnh. Không request ngay khi splash vừa hiện.

Khuyến nghị timing giống web:

- sau khi user đã signed-in
- sau khi user hoàn thành ít nhất một flow học
- hoặc khi user chủ động mở notification settings

## 6.3. Foreground presentation

Android nên có ít nhất một high-importance notification channel cho:

- grading result
- reminder/re-engagement
- admin broadcast

Nếu không muốn foreground push hiển thị thô, dùng `flutter_local_notifications` để render local notification/banner theo payload đã normalize.

## 6.4. Background handler

Mobile cần support:

- foreground receive
- background tap open
- terminated open

Push payload phải luôn có đủ `data` để route được ngay cả khi OS không chuyển đủ phần `notification`.

## 7. iOS setup bắt buộc

## 7.1. Capabilities trong Xcode

Trong `ios/Runner.xcworkspace`, bật:

- Push Notifications
- Background Modes
- Background fetch
- Remote notifications

Nếu thiếu các capability này, FCM iOS sẽ rất dễ rơi vào trạng thái token có nhưng background delivery hoặc open flow không ổn định.

## 7.2. APNs key trong Firebase console

Phải upload APNs auth key `.p8` vào Firebase Console:

- Firebase Console
- Project Settings
- Cloud Messaging

Thông tin cần có:

- `.p8` file
- Key ID
- Apple Team ID

Nếu chưa upload APNs key, iOS app sẽ không có đường push production đúng nghĩa.

## 7.3. Permission và APNs token

iOS phải gọi `requestPermission()` theo ngữ cảnh. Ngoài ra, trước các FCM API call quan trọng nên chờ APNs token đã sẵn sàng.

Điểm này quan trọng vì Firebase docs cho Flutter có lưu ý từ iOS SDK 10.4.0 trở lên: APNs token phải có trước khi gọi một số FCM API.

## 8. Contract runtime cho push trên mobile

## 8.1. Token lifecycle

Tối thiểu phải có các bước:

1. user signed-in
2. app kiểm tra local permission state
3. nếu permission đã grant, lấy FCM token
4. gửi token lên backend
5. subscribe `onTokenRefresh` và gửi lại token mới
6. khi logout, clear local session và dừng push flow của user cũ

## 8.2. Backend contract hiện tại và đề xuất mở rộng

Web hiện gọi:

```txt
POST /api/auth/fcm-token
```

Payload hiện tại ở web:

```json
{
  "fcmToken": "...",
  "os": "Windows",
  "browser": "Chrome"
}
```

Với mobile, semantics nên giữ nguyên nhưng contract nên mở rộng để bớt web-centric:

```json
{
  "fcmToken": "...",
  "platform": "ANDROID",
  "os": "Android 14",
  "deviceModel": "Pixel 8",
  "appVersion": "1.2.3",
  "buildNumber": "45"
}
```

Nếu backend chưa kịp mở contract, tối thiểu vẫn phải lưu được:

- `fcmToken`
- `os`
- một marker thay cho `browser`, ví dụ `mobile-app`

Nhưng đây chỉ là phương án tương thích tạm. Về lâu dài backend nên hiểu thiết bị mobile là first-class entity.

## 8.3. Payload contract để route giống web

Push payload nên mang đủ data fields sau:

- `notificationId`
- `type`
- `actionUrl`
- `fallbackActionUrl`
- `referenceType`
- `referenceId`
- `reason`
- `estimatedMinutes`
- `triggerType`
- `createdAt`

Phần title/body có thể nằm ở `notification`, nhưng routing không được phụ thuộc duy nhất vào đó.

## 8.4. Action flow khi user chạm push

Mobile phải đi theo cùng thứ tự resolve như web:

1. ưu tiên `actionUrl`
2. fallback `fallbackActionUrl`
3. fallback theo `referenceType`
4. nếu là learning session, gọi `rememberLearningLaunch(...)`
5. track notification open/click
6. navigate

Không được có nhánh “push route riêng” tách khỏi notification action resolver.

## 8.5. Foreground behavior

Khi app đang mở:

- không mở màn ngay lập tức
- hiện banner/notice trước
- để user chủ động chạm vào mới route

Semantics này phải giữ giống web để tránh UX quá xâm lấn.

## 9. Notification settings trên mobile

UI settings nên phản ánh 2 lớp khác nhau:

1. OS/device permission
   - granted
   - denied
   - provisional nếu iOS dùng

2. app-level preferences từ backend
   - `allowPush`
   - `allowEmail`
   - `allowVocabularyReminder`
   - `allowGradingResult`
   - `allowAdminBroadcast`

`allowPush = true` không có nghĩa thiết bị đã grant permission. Mobile UI phải hiển thị rõ hai trạng thái này, không gộp mù vào một toggle.

## 10. Firebase App Distribution

## 10.1. Mục tiêu

App Distribution của dự án này nên phục vụ:

- QA nội bộ
- test nhanh bản `dev` hoặc `staging`
- share build trước khi lên store

Không nên coi App Distribution là bước phụ. Với mobile, đây là đường release pre-production chính.

## 10.2. Thông tin bắt buộc phải lưu rõ

Cho mỗi platform cần có:

- Firebase Project ID
- Firebase App ID
- package name Android
- bundle identifier iOS
- tester group aliases
- tài khoản hoặc service account để upload
- signing config tương ứng build phân phối

Khuyến nghị lưu trong tài liệu hoặc CI secret names như:

```txt
FIREBASE_PROJECT_ID
FIREBASE_APP_ID_ANDROID
FIREBASE_APP_ID_IOS
FIREBASE_TESTER_GROUPS
GOOGLE_APPLICATION_CREDENTIALS
FIREBASE_TOKEN
```

## 10.3. Cách upload khuyến nghị: Firebase CLI

### Android

Build trước:

```bash
flutter build apk --release
```

hoặc:

```bash
flutter build appbundle --release
```

Upload:

```bash
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app "$FIREBASE_APP_ID_ANDROID" \
  --groups "$FIREBASE_TESTER_GROUPS" \
  --release-notes-file docs/mobile/release-notes-android.txt
```

### iOS

Build IPA:

```bash
flutter build ipa --release
```

Upload:

```bash
firebase appdistribution:distribute build/ios/ipa/Runner.ipa \
  --app "$FIREBASE_APP_ID_IOS" \
  --groups "$FIREBASE_TESTER_GROUPS" \
  --release-notes-file docs/mobile/release-notes-ios.txt
```

## 10.4. Cách upload thay thế

Nếu Android CI đã native-heavy:

- dùng App Distribution Gradle plugin

Nếu iOS CI đã dùng fastlane:

- dùng plugin `firebase_app_distribution`

Nhưng nếu pipeline hiện tại chưa ổn định, đừng bắt đầu bằng hai đường riêng này. Firebase CLI gọn hơn cho phase đầu.

## 10.5. Checklist trước khi upload

Android:

- app đã signed đúng keystore phân phối
- `applicationId` khớp Firebase app
- build có thể cài trên máy test
- notification permission flow đã test trên Android 13+

iOS:

- app đã signed đúng team/provisioning profile
- bundle identifier khớp Firebase app
- APNs auth key đã upload ở Firebase
- Push Notifications và Remote notifications capability đã bật
- IPA build thành công trên thiết bị thật

Chung:

- tester groups đã tạo sẵn trong Firebase console
- release notes có version/build number
- QA biết app này map tới environment nào

## 10.6. Nhóm tester

Nên tạo alias ổn định ngay từ đầu, ví dụ:

```txt
qa-team
internal-dev
product-review
```

Không nên upload thủ công bằng danh sách email dài ở mỗi lần release nếu team sẽ build thường xuyên.

## 10.7. Release notes tối thiểu

Mỗi build App Distribution nên có:

- version
- build number
- environment
- thay đổi chính
- known issues nếu có

Ví dụ:

```txt
1.2.3+45
env: staging
- add push permission prompt after login completion
- add notification open routing via actionUrl
- fix foreground reminder banner rendering
known issues:
- iOS terminated open chưa track analytics ở lần cold start đầu tiên
```

## 11. Checklist implement cho team mobile

## 11.1. Flutter packages

- thêm `firebase_core`
- thêm `firebase_messaging`
- optional `flutter_local_notifications`

## 11.2. Bootstrap

- init Firebase trước app shell
- register background message handler
- bootstrap auth trước khi quyết định sync token

## 11.3. Permission UX

- tạo prompt mềm trong app
- chỉ gọi system permission sau khi user đồng ý
- map permission state ra UI settings

## 11.4. Token sync

- lấy token sau khi grant permission
- sync ngay lên backend
- re-sync khi `onTokenRefresh`
- re-sync lại khi login lại hoặc app restart nếu cần

## 11.5. Routing

- parse payload data
- normalize sang notification action model dùng chung
- reuse action resolver từ phase 3
- remember learning launch khi phù hợp

## 11.6. Distribution

- chốt App ID Android/iOS
- chốt tester groups
- thêm command upload vào CI hoặc script release
- chuẩn hóa file release notes

## 12. Test checklist

- Android 13 fresh install, deny permission, app không crash
- Android 13 fresh install, allow permission, token được sync
- iOS allow permission, token được sync sau khi APNs token sẵn sàng
- foreground push hiện banner/notice
- tap push từ background mở đúng route
- tap push từ terminated mở đúng route
- learning launch context vẫn đúng khi mở từ push
- đổi FCM token thì backend nhận token mới
- build Android upload được lên App Distribution
- build iOS upload được lên App Distribution

## 13. Rủi ro cần tránh

- xin permission quá sớm làm giảm opt-in rate
- route theo `notification.title` thay vì `data.actionUrl`
- chỉ test foreground mà không test terminated open
- iOS có FCM token nhưng quên APNs key/capability nên không nhận push thật
- reuse payload `browser` cho mobile quá lâu làm backend khó quản lý device
- dùng nhiều Firebase project cho cùng một luồng notification mà không có naming discipline

## 14. Kết luận delivery

Nếu cần chốt theo thứ tự triển khai ít rủi ro nhất:

1. đăng ký app Android/iOS trong cùng Firebase project
2. chạy `flutterfire configure`
3. init Firebase + permission prompt mềm + token sync
4. nối push open vào shared action resolver
5. test foreground/background/terminated
6. chốt Firebase App IDs + tester groups
7. thêm upload command App Distribution vào local release flow hoặc CI

Nếu làm đúng thứ tự này, mobile sẽ có push semantics sát web và có đường phân phối build ổn định cho QA ngay từ đầu.
