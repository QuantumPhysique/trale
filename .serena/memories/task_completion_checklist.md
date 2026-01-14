# Task Completion Checklist

When completing a coding task, run the following to ensure quality:

1. **Format code**: `dart format .`
2. **Generate code**: `dart run build_runner build --delete-conflicting-outputs`
3. **Run linter**: `flutter analyze`
4. **Run tests**: `flutter test`
5. **Build debug**: `flutter build apk --debug` (or `flutter build ios --debug` for iOS)
6. **Check integration tests**: `flutter drive --driver=test_driver/driver_test.dart --target=test_driver/driver_main.dart`
7. **Verify no errors**: Ensure all commands pass without errors
8. **Commit changes**: Use git add, commit with descriptive message

If any issues, fix them before considering the task complete.