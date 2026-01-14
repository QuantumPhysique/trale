# Task Completion Checklist

When completing a coding task, run the following to ensure quality:

1. **Format code**: `dart format .`
2. **Run linter**: `flutter analyze`
3. **Run tests**: `flutter test`
4. **Build debug**: `flutter build apk --debug` (or ios if applicable)
5. **Check integration tests**: `flutter drive --driver=test_driver/driver_test.dart --target=test_driver/driver_main.dart`
6. **Verify no errors**: Ensure all commands pass without errors
7. **Commit changes**: Use git add, commit with descriptive message

If any issues, fix them before considering the task complete.