# CI & Tests — Current State

- CI workflows present:
  - `.github/workflows/build-flutter.yml` — runs `flutter pub get`, `flutter build apk` (release) and other checks
  - `.github/workflows/flutter-release.yml` — release build steps

- Tests present locally:
  - Unit/widget tests: `test/widget_test.dart`, `test/widget/`, `test/db/`
  - Integration tests: `test_driver/driver_test.dart` (device-based integration tests for check-in flows)
  - Driver tests: `test_driver/driver_main.dart` (test harness)

- Current Coverage:
  - ✅ Unit tests: Database CRUD operations, migrations
  - ✅ Integration tests: Check-in form flow, emotional check-ins, calendar navigation
  - ✅ Widget tests: Calendar, form validation, screen rendering
  - ✅ Device tests: Pixel 7 (Android 9+, minSdk 28) verified
  - ⏸️ Playwright screenshots: Available in `app/screenshots/` but not automated

- Recommendations:
  - Add `integration_test/` directory for standard Flutter integration tests if needed
  - Consider adding device matrix to CI (emulator) for smoke tests
  - Add `format` and `analyze` step in CI if not already present
  - Playwright tests are in root `tests/` directory for end-to-end testing

- Updated as of January 14, 2026: Integration tests implemented and passing\n