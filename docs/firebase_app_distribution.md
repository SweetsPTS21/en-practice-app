# Firebase Mobile Setup And Distribution

Tài liệu này là bản tổng hợp từ:

- `docs/flutter-mobile-firebase-migration-handoff.md`
- scaffold App Distribution đã thêm trong repo Flutter này

Mục tiêu là giữ một source of truth ngắn gọn, có thể thực thi ngay, cho việc:

- chốt identity app mobile
- chuẩn bị Firebase runtime cho push semantics giống web
- chuẩn bị release plumbing để upload Android/iOS lên Firebase App Distribution

## 1. Identity đã chốt

- Product name: `EN Practice`
- Android application ID: `com.swpts.enpractice`
- Android namespace: `com.swpts.enpractice`
- iOS bundle identifier: `com.swpts.enpractice`

Các giá trị này đã được cập nhật trong repo. Khi đăng ký app trong Firebase Console, phải dùng đúng các ID này.

## 2. Những gì repo đã có sẵn

### 2.1. App identity và release naming

Đã cập nhật:

- Android label: `EN Practice`
- iOS display name: `EN Practice`
- Flutter app title: `EN Practice`
- Web app title/manifest name: `EN Practice`

### 2.2. App Distribution scaffolding

Repo hiện đã có:

- `.env.firebase.example`
- `android/key.properties.example`
- `config/firebase/app_distribution/release_notes.txt`
- `config/firebase/app_distribution/testers.example.txt`
- `config/firebase/app_distribution/groups.example.txt`
- `scripts/configure_flutterfire.ps1`
- `scripts/distribute_firebase_android.ps1`
- `scripts/distribute_firebase_ios.sh`

Ngoài ra, Android Firebase native config hiện đã có:

- `android/app/google-services.json`
- Google Services Gradle plugin đã được apply đúng vào module app

### 2.3. Android release signing fallback

`android/app/build.gradle.kts` hiện:

- ưu tiên `android/key.properties` nếu đã cấu hình upload keystore thật
- fallback về debug signing nếu file đó chưa có, để local release build không bị chặn

### 2.4. Push architecture đã có sẵn ở mức abstraction

Repo đã có sẵn khung logic:

- permission snapshot / prompt timing
- token sync service
- foreground message handling
- background/open route handling
- shared action resolver bridge

Runtime hiện đã có:

- bootstrap Firebase an toàn trong `main.dart`
- background message handler registration
- `FirebasePushPlatformAdapter` dùng `firebase_messaging`
- fallback về `NoopPushPlatformAdapter` nếu build/platform chưa có Firebase native config hợp lệ

Ngoài ra, token sync hiện vẫn đang dùng payload tương thích web cũ:

- `token`
- `os`
- `browser`

Theo handoff, phần này nên được nâng lên contract mobile-first hơn khi backend sẵn sàng, ví dụ thêm:

- `platform`
- `deviceModel`
- `appVersion`
- `buildNumber`

## 3. Những gì vẫn còn thiếu trước khi coi là Firebase-ready

### 3.1. Firebase runtime chưa được nối thật

Hiện repo vẫn chưa có:

- contract token sync mobile-first thay cho payload còn mang trường `browser`

Repo hiện đã có:

- `lib/firebase_options.dart`
- output từ `flutterfire configure` cho `web`, `android`, `ios`, `macos`, `windows`

### 3.2. Native Firebase config chưa có trong repo

Hiện repo chưa có:

- `ios/Runner/GoogleService-Info.plist`

`android/app/google-services.json` hiện đã có trong workspace và đã được Gradle xử lý thành công.

`flutterfire configure` đã sinh `lib/firebase_options.dart`, nhưng file native iOS `GoogleService-Info.plist` vẫn chưa xuất hiện trong workspace hiện tại. Cần bổ sung file này thủ công từ Firebase Console hoặc chạy lại cấu hình Apple-platform trên môi trường phù hợp.

Các file native config không nên commit thẳng nếu team muốn quản lý bằng secret/CI artifact, nhưng ít nhất phải tồn tại trong môi trường build thật hoặc được thay bằng output từ quy trình `flutterfire configure` + secret injection đã chốt.

### 3.3. iOS push capabilities chưa được bật trong project file

Theo handoff và Firebase FCM docs, iOS cần bật:

- Push Notifications
- Background Modes
- Background fetch
- Remote notifications

Điểm này hiện chưa được xác nhận trong repo Flutter hiện tại và vẫn cần thao tác trong Xcode / signing environment thật.

## 4. Packages đã chuẩn bị

Repo đã thêm dependency tối thiểu:

- `firebase_core`
- `firebase_messaging`

Dependency đã có và app đã bootstrap Firebase theo native default config khi khả dụng. Tuy nhiên cấu hình vẫn chưa hoàn chỉnh theo chuẩn FlutterFire do chưa có `firebase_options.dart`.
Dependency đã có và app đã bootstrap Firebase bằng `DefaultFirebaseOptions.currentPlatform`.

## 5. Bước bắt buộc tiếp theo

## 5.1. Dùng đúng Firebase project của web

Theo handoff, mobile nên dùng cùng Firebase project với web để không tách rời:

- notification infrastructure
- App Distribution
- tester groups
- APNs / FCM operations

## 5.2. Chạy FlutterFire CLI

Từ root dự án:

```bash
flutter pub get
dart pub global activate flutterfire_cli
firebase login
flutterfire configure \
  --android-package-name com.swpts.enpractice \
  --ios-bundle-id com.swpts.enpractice
```

Sau bước này, tối thiểu phải có:

- `lib/firebase_options.dart`
- mapping Android/iOS app đúng Firebase project

Theo Firebase Flutter setup docs, đây là đường chuẩn để cấu hình Flutter app với Firebase và sinh `firebase_options.dart`.

Trên máy Windows hiện tại của team, có thể dùng helper script trong repo:

```powershell
firebase login
.\scripts\configure_flutterfire.ps1
```

Script này đã khóa sẵn:

- `--project en-practice`
- `--android-package-name com.swpts.enpractice`
- `--ios-bundle-id com.swpts.enpractice`

## 5.3. Hoàn tất bootstrap runtime

Sau khi đã có `firebase_options.dart`, mới nên sửa `main.dart` để:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
3. bootstrap auth/session
4. bootstrap push lifecycle

Repo hiện đã chuyển sang `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.

## 5.4. Nối Firebase Messaging vào adapter hiện có

Nên giữ lại kiến trúc hiện tại và chỉ thay implementation của `PushPlatformAdapter`:

- `getCurrentPermissionStatus()`
- `requestPermission()`
- `getToken()`
- `onTokenRefresh`
- `onForegroundMessage`
- `onMessageOpenedApp`
- `getInitialMessage()`

Như vậy semantics push hiện tại sẽ giữ giống web mà không phải viết lại flow.

## 5.5. Hoàn tất native setup cho push

Android:

- giữ `android.permission.POST_NOTIFICATIONS`
- chỉ request runtime permission theo ngữ cảnh trong app

iOS:

- bật Push Notifications capability
- bật Background Modes:
    - Background fetch
    - Remote notifications
- upload APNs auth key `.p8` lên Firebase Console

## 6. Environment variables chuẩn nên dùng

Nên thống nhất theo naming này:

```txt
FIREBASE_PROJECT_ID
FIREBASE_APP_ID_ANDROID
FIREBASE_APP_ID_IOS
FIREBASE_TESTER_GROUPS
GOOGLE_APPLICATION_CREDENTIALS
FIREBASE_TOKEN
```

`.env.firebase.example` trong repo đã được đổi theo naming này. Script upload vẫn hỗ trợ tên cũ để tránh gãy local setup đang có.

Giá trị Android hiện đã biết từ `google-services.json`:

```txt
FIREBASE_PROJECT_ID=en-practice
FIREBASE_APP_ID_ANDROID=1:236428171454:android:1c838c4855d3f5146c66ef
```

## 7. Cách upload build hiện tại

### 7.1. Android

PowerShell:

```powershell
.\scripts\distribute_firebase_android.ps1
```

Script hiện hỗ trợ:

- build APK hoặc AAB
- `FIREBASE_APP_ID_ANDROID`
- `FIREBASE_RELEASE_NOTES_FILE`
- `FIREBASE_TESTERS` hoặc `FIREBASE_TESTERS_FILE`
- `FIREBASE_TESTER_GROUPS` hoặc `FIREBASE_GROUPS_FILE`
- `FIREBASE_TOKEN`

### 7.2. iOS

macOS:

```bash
bash ./scripts/distribute_firebase_ios.sh
```

Script hiện hỗ trợ cùng naming env như Android và upload IPA bằng Firebase CLI.

## 8. Checklist trước khi upload

Android:

- app signed bằng upload keystore thật
- `applicationId = com.swpts.enpractice`
- Android app đã được register trong Firebase với đúng package name
- App ID Android đã điền vào `.env.firebase`

iOS:

- bundle identifier là `com.swpts.enpractice`
- iOS app đã được register trong Firebase với đúng bundle ID
- APNs key đã upload vào Firebase Console
- Xcode capabilities đã bật đúng
- signing/provisioning profile build được IPA thật

Chung:

- đã có tester groups trong Firebase Console
- đã có release notes file
- đã chốt mobile đang map vào Firebase project nào

## 9. Kết luận trạng thái hiện tại

Repo hiện đã sẵn sàng ở mức preparation:

- app identity đã đúng
- package/bundle ID đã đúng
- app name đã đúng
- Android manifest đã có `POST_NOTIFICATIONS`
- dependency Firebase tối thiểu đã có trong `pubspec.yaml`
- Android `google-services.json` đã vào đúng chỗ và được Gradle xử lý
- `main.dart` đã bootstrap Firebase theo native config khi khả dụng
- Firebase Messaging adapter đã được nối với fallback an toàn
- App Distribution scripts/env/docs đã có

Nhưng repo chưa sẵn sàng ở mức runtime Firebase hoàn chỉnh cho push, vì vẫn còn thiếu:

- iOS push capabilities + APNs setup
- `GoogleService-Info.plist` cho iOS

## 10. Nguồn đối chiếu chính thức

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Firebase Cloud Messaging for Flutter: https://firebase.google.com/docs/cloud-messaging/flutter/get-started
- Firebase App Distribution Android CLI: https://firebase.google.com/docs/app-distribution/android/distribute-cli
- Firebase App Distribution Android Gradle: https://firebase.google.com/docs/app-distribution/android/distribute-gradle
- Firebase App Distribution iOS CLI: https://firebase.google.com/docs/app-distribution/ios/distribute-cli
- Firebase App Distribution iOS fastlane: https://firebase.google.com/docs/app-distribution/ios/distribute-fastlane
