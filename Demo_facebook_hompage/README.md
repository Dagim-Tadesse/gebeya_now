# Demo Facebook Homepage — Flutter App

A simple, learning-focused Flutter app that simulates parts of a Facebook-like UI and sign-in flow. It uses Firebase for auth (including Google Sign-In) and Firestore for basic data interactions.

## Overview

- Home feed UI and navigation
- Watch page and Friends page stubs for layout practice
- Splash screen and sign-in flow
- Firebase Auth + Google Sign-In
- Firestore integration

## Tech Stack

- Flutter (Dart)
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`
- Google Sign-In: `google_sign_in`

## Project Structure

- [lib/main.dart](lib/main.dart): App entry point
- [lib/splash_screen.dart](lib/splash_screen.dart): Splash/startup
- [lib/sign_in_page.dart](lib/sign_in_page.dart): Sign-in UI + flow
- [lib/auth_service.dart](lib/auth_service.dart): Auth helpers (Firebase/Google)
- [lib/facebook_home_page.dart](lib/facebook_home_page.dart): Home feed
- [lib/facebook_watch_page.dart](lib/facebook_watch_page.dart): Watch page
- [lib/facebook_friends_page.dart](lib/facebook_friends_page.dart): Friends page
- [lib/firebase_options.dart](lib/firebase_options.dart): Generated Firebase config
- Android Firebase config: [android/app/google-services.json](android/app/google-services.json)

## Setup

1. Ensure Flutter SDK and Android SDK are installed and configured.
2. From this folder, install dependencies:

```powershell
flutter pub get
```

3. Initialize Firebase (if reconfiguring):

- Existing configs are already present (`lib/firebase_options.dart`, `android/app/google-services.json`). If you need to regenerate:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

## Run

- On an Android emulator/device:

```powershell
flutter run
```

- Specify a particular emulator/device:

```powershell
flutter run -d emulator-5554
```

## Build

```powershell
flutter build apk --debug
```

If Gradle fails to download artifacts (e.g., `storage.googleapis.com` not reachable), check your internet connection, DNS/proxy settings, or configure Gradle proxy in `%UserProfile%\.gradle\gradle.properties`.

## Testing

- The default template test at [test/widget_test.dart](test/widget_test.dart) may not match this app (it’s based on the counter example). You can update it to reflect real widgets or temporarily skip it.

## Notes & Tips

- Use `Timer` for repeated timed actions and `Future` for one-shot async operations.
- Prefer `Navigator` for page transitions and keep widget trees simple and readable.
- Assets are loaded from [assets/images](assets/images); ensure they’re declared under `flutter.assets` in [pubspec.yaml](pubspec.yaml).

## Troubleshooting

- Analyzer shows many red errors in VS Code:
  - Ensure VS Code points to the correct Flutter SDK (Command Palette → “Flutter: Change Flutter SDK”).
  - Restart the Dart Analysis Server (Command Palette → “Dart: Restart Analysis Server”).
- Android build network errors:
  - Verify access to `https://storage.googleapis.com`.
  - Configure proxy in Gradle if behind a corporate network.
