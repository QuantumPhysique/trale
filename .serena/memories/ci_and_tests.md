# CI & Tests — Current State

- CI workflows present:
  - `.github/workflows/build-flutter.yml` — runs `flutter pub get`, `flutter build apk` (release) and other checks
  - `.github/workflows/flutter-release.yml` — release build steps

- Tests present locally:
  - Unit/widget tests: `test/widget_test.dart`
  - No `integration_test/` directory currently in the repository (Agent_Instructions.md contains example integration tests to be added for T2–T9 flows).

- Gaps & Recommendations:
  - Add `integration_test/` tests for database, camera, check-in form, emotional check-in, calendar, and immutability (Agent_Instructions has canonical examples).
  - Add device verification steps (adb) as part of local QA; consider adding device matrix to CI (emulator) for at least smoke tests.
  - Consider adding a `format` and `analyze` step in CI if not already present.
