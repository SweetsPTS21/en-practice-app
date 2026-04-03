# enpractice

Flutter app scaffold for the `enpractice` mobile project.

## Current status

The project builds successfully on Android in the current setup.

Verified locally on 2026-04-02:

- `flutter analyze` passes
- `flutter test` passes
- `flutter build apk --debug` passes
- debug APK installs and launches on Android emulator `emulator-5554`

Output APK:

- `build/app/outputs/flutter-apk/app-debug.apk`

## Local environment used

- Flutter `3.41.6`
- Dart `3.11.4`
- Android Gradle Plugin `8.11.1`
- Gradle `8.14`
- Kotlin `2.2.20`
- Java `17` via Android Studio JBR

## Run the app

### From terminal

```powershell
flutter pub get
```

Run virtual device (from Android Studio)

```powershell
emulator -list-avds
emulator -avd <avd>
flutter devices
flutter run -d emulator-5554
```

If you want to build an APK only:

```powershell
flutter build apk --debug
```

### From Android Studio

1. Open the project root `enpractice`
2. Wait for Gradle and Flutter indexing to finish
3. Start an Android emulator from Device Manager
4. Choose the emulator as the target device
5. Run `lib/main.dart`

## Android setup still recommended

`flutter doctor -v` is mostly healthy, but Android tooling is not fully complete yet.

Current doctor notes:

- Android SDK is detected
- emulator is detected
- `cmdline-tools` is missing
- Android license status is reported as unknown

To finish Android setup in Android Studio:

1. Open `Android Studio`
2. Go to `More Actions` -> `SDK Manager`
3. Open the `SDK Tools` tab
4. Check `Android SDK Command-line Tools (latest)`
5. Apply the install
6. Restart terminal/Android Studio
7. Run `flutter doctor -v` again

After `cmdline-tools` is installed, run:

```powershell
flutter doctor --android-licenses
```

Accept all licenses, then verify again:

```powershell
flutter doctor -v
```

## Notes

- `android/local.properties` is machine-specific and should not be committed.
- The `Visual Studio` warning in `flutter doctor` only matters for Windows desktop builds. It does not block Android development.
- The current Android package id is `com.example.enpractice`.

## Reference

- [Flutter docs](https://docs.flutter.dev/)
