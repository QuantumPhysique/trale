# CLAUDE.md — Trale

Flutter body-weight diary app. Android only. Data on-device (Hive + SharedPreferences). All commands run from `app/`.

## Build Commands

```bash
cd app
flutter pub get --enforce-lockfile   # install deps
make generate                        # code generators (changelog, Hive adapters)
make run                             # run app
make build                           # release APK
make analyze                         # static analysis
make test                            # tests
make hive                            # regenerate Hive type adapters (if models change)
make clean                           # clean build artifacts
make install-hooks                   # install git pre-commit hooks (run once after clone)
```

## Coding Conventions

- Always specify types (`always_specify_types` lint is on)
- Doc comments required on public APIs (`public_member_api_docs` lint)
- Prefer const constructors, single quotes, 80 char line limit
- Enums use extensions for behavior (see existing enum files for pattern)
- `l10n-gen/` is generated — do not edit
- Always use `TraleTheme` and `Theme.of(context)` for theming — no hardcoded colors/styles

## Key Patterns

**State:** Provider + ChangeNotifier. `TraleNotifier` is the central hub.

**Singletons** (factory → _instance): TraleNotifier, Preferences, MeasurementDatabase, MeasurementInterpolation, MeasurementStats, NotificationService.

**Adding a setting:** add default + getter/setter in `preferences.dart`, init in `loadDefaultSettings()`, property + `notifyListeners()` in `traleNotifier.dart`.

**Modifying data model:** edit `measurement.dart` (bump `@HiveField` IDs, never reuse), run `make hive`.

**Test DI:**
```dart
Preferences.testInstance = Preferences.forTesting(mockPrefs);
MeasurementDatabase.testInstance = MeasurementDatabase.forTesting(mockBox);
// tearDown: Preferences.resetInstance(); MeasurementDatabase.resetInstance();
```

**Shared constants:** `lib/core/constants.dart` (`dayInMs`, `kcalPerKg`) — use instead of magic numbers.
