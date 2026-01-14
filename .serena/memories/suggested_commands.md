# Suggested Commands for Development

## Environment Setup
- `flutter doctor`: Check Flutter installation and dependencies
- `flutter pub get`: Install project dependencies

## Running the App
- `flutter run`: Run the app in debug mode on connected device/emulator
- `flutter run --release`: Run in release mode

## Building
- `flutter build apk`: Build Android APK
- `flutter build ios`: Build iOS app (requires macOS)
- `flutter build appbundle`: Build Android App Bundle

## Testing
- `flutter test`: Run unit and widget tests
- `flutter drive --driver=test_driver/driver_test.dart --target=test_driver/driver_main.dart`: Run integration tests

## Code Quality
- `flutter analyze`: Run static analysis (linting)
- `dart format .`: Format Dart code
- `dart fix --apply`: Apply automatic fixes

## Other
- `flutter clean`: Clean build artifacts
- `flutter pub outdated`: Check for outdated dependencies
- `flutter pub upgrade`: Upgrade dependencies