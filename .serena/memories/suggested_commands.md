# Suggested Commands for Development

## Setup
- flutter pub get
- dart pub get

## Codegen
- dart run build_runner build --delete-conflicting-outputs

## Lint/Format/Test
- flutter analyze
- flutter test
- dart format .
- flutter test test/widget_test.dart

## Build & Device (debug)
- flutter build apk --debug
- adb install -r build/app/outputs/flutter-apk/app-debug.apk
- adb shell am start -n com.example.trale/.MainActivity
- adb devices
- export DEVICE_ID=$(adb devices | grep -v "List" | awk '{print $1}' | head -1)

## Integration tests on device
- flutter test integration_test/<test_file>.dart -d $DEVICE_ID

## Build (release) & release packaging
- flutter build appbundle --release
- flutter build apk --split-per-abi --release
- fastlane (see `fastlane/` metadata)

## Git / PR workflow (used by agent instructions)
- git checkout -b feature/my-feature
- git add . && git commit -m "feat: ..."
- git push -u origin feature/my-feature
- Create pull request, address CI and CodeRabbit feedback, then squash-merge and delete branch

## Useful helper commands from Agent_Instructions.md
- adb shell pm grant $PKG android.permission.CAMERA
- adb exec-out screencap -p > screenshots/<name>.png
- adb shell "run-as $PKG ls /data/data/$PKG/app_flutter/ | grep trale.db"

