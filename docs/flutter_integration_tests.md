# Flutter Integration Tests (scraped)

(Extracted from https://docs.flutter.dev/testing/integration-tests)

- Setup: add `integration_test` to `dev_dependencies`, create `integration_test/` directory, and add test files.
- Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` in tests.
- Run with `flutter test integration_test/<test_file>.dart` and choose device/emulator.
- Example: test a FAB increment by key `ValueKey('increment')`.

(Full extracted content saved.)