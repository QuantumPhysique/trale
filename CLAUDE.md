# trale

Flutter body-weight diary. Android only, all data on-device (Hive + SharedPreferences). The app builds on the sibling package `../quantumphysique` (theme, notifier and preferences base classes, widget library, changelog generator). All commands run from `app/`.

## Setup

```bash
cd app
flutter pub get --enforce-lockfile
make generate        # changelog.g.dart from ../CHANGELOG.md
```

## Tasks

| Task | Command |
|---|---|
| Run | `make run` |
| Format | `make format` |
| Analyze | `make analyze` |
| Tests | `make test` |
| One test file | `flutter test test/core/units_test.dart` |
| Changelog check (as CI) | `dart run quantumphysique:generate_changelog --check` |
| Hive adapters | `make hive` (after editing `measurement.dart`) |
| Release APK | `make build` |
| Accrescent APK set | `make build-apks` (needs bundletool + `android/key.properties`) |

**Format, analyze and test once, on the finished change.** They are the gate before commit and PR, not a step after every edit. In between, run only what answers a concrete question — one test file, usually.

CI (`build-flutter.yml`) runs `dart format --set-exit-if-changed`, `dart analyze`, `dependency_validator`, the changelog check and `flutter test` on every PR.

## Branching and release

- `main` is the only long-lived branch; feature branches `feat/<topic>`, `fix/<topic>`, `ci/<topic>`, `chore/<topic>` off `main`, back by merge commit. Never commit to `main` directly.
- Every commit lands on `main` as it is (no squash), so every commit is a conventional commit — see `/commit`. The PR title uses the same format.
- Versions are prepared with `/release`: a `release/prepare_vX.Y.Z` branch with one `chore: prepare vX.Y.Z` commit that turns `[Unreleased]` in `CHANGELOG.md` into `[X.Y.Z] - <date>`, bumps `version:` in `pubspec.yaml` (name and build number), adds `fastlane/metadata/android/{en-US,de}/changelogs/<build>3.txt` (build number followed by the arm64 ABI digit) and regenerates `changelog.g.dart`. Only after merge: a GitHub release tagged `vX.Y.Z` with the changelog section as body; `flutter-release.yml` builds and uploads the APKs, the AAB and the Accrescent `.apks`. Never create tags by hand.

## Changelog

`CHANGELOG.md` is read by users, in the app and on the stores. Every change adds to `[Unreleased]`, in the sections `Added Features and Improvements 🙌`, `Bugfix 🐛`, `Other Changes`, `API Changes Warning ⚠️`.

- A change users notice gets one short line: what changed for them. No class or widget names, no cause, no implementation
  - Bad: `Fixed reminders firing at the wrong hour: the device time zone was matched by its abbreviation`
  - Good: `Fixed reminders firing at the wrong hour`
- Bug fixes start with `Fixed …`
- A change tied to a GitHub issue ends with it: `Fixed the calendar with a custom first day of the week (#417)`
- Everything users cannot see — refactoring, tests, CI, lint fixes, build tooling — is covered by one shared line under `Other Changes`: `Minor improvements to the code base`. Add it if it is missing, never a second one
- A broken store release is the exception users do notice: `Fixed the F-Droid release`
- Under `Added Features and Improvements`:
  - Flutter is the only dependency named, with its version: `Use the latest Flutter (3.47) with upgraded deps`. Without a Flutter upgrade, other upgrades get `Upgraded deps` under `Other Changes`
  - A new Android target SDK: `Target Android 16 (SDK 36)`
- Translations from Weblate: `Improved translation`. A new language: `<Hello world in that language>! Thx to the community, the app is now available in <Language> 🎉`

Then `make generate` and commit `app/lib/core/changelog.g.dart` with it; CI fails when it is stale.

## Unreleased changes

Released means listed under a version heading in `CHANGELOG.md` (equivalently: tagged). Everything else — `[Unreleased]` on `main`, any branch, your own earlier commits in a PR — is not deployed. Changing or removing it needs no deprecation path, no compatibility shim, no data migration, and no test asserting it is gone: delete the old code together with its tests, and say so in one line of the PR body. A `@HiveField` id or preference key added since the last release may be changed or dropped freely.

Released state is different: Hive fields, preference keys and the backup format must keep loading. New `@HiveField` ids, never reuse one; explicit migration, not a silent fallback.

## Dev loop

1. Branch off `main`.
2. Implement the whole change in `lib/`, plus its `CHANGELOG.md` line as the Changelog section says. Tests only where the Tests section below asks for one.
3. Once, on the finished change: `make format`, `make analyze`, `make test`, `make generate`. Fix what they report.
4. `/commit`, then `/pr`.

## Project structure

- `lib/core/` — model, persistence, statistics, preferences, notifier; `preferences/` and `trale_notifier/` hold `part` files grouped by concern
- `lib/pages/`, `lib/widget/` — UI
- `lib/l10n/` — ARB files; `lib/l10n-gen/` is generated, never edit it
- `test/core/`, `test/widget/` — suites; shared setup in `test/helpers/`
- `../quantumphysique/` — app-agnostic Flutter code shared with other apps; `../CHANGELOG.md`, `../fastlane/` — release metadata

## Code

- Types everywhere (`always_specify_types`); `const` where possible; single quotes; 80 columns
- Theme only through `QPTheme.of(context)` and `Theme.of(context)` — no literal colours, sizes or radii
- Strings only through `context.l10n`; new keys go in `app_en.arb` and `app_de.arb`. The other languages come from Weblate — never edit them by hand
- `qp_*` keys are the vocabulary shared with the other quantumphysique apps, which copy them over verbatim, so they must never name trale or weight tracking. A `QPStrings` field that does (`translateSubtitle`, `reminderSubtitle`) is fed from an app-owned key in `l10n_extension.dart`; `test/core/qp_strings_test.dart` enforces it
- Enums carry behaviour in extensions (see `units.dart`)
- Constants in `lib/core/constants.dart` (`dayInMs`, `kcalPerKg`), no magic numbers
- Adding a setting: getter/setter in the matching `preferences/*.dart` part, default in `loadDefaultSettings()`, property plus `notifyListeners()` in the matching `trale_notifier/*.dart` part
- Anything not about weight tracking belongs in `quantumphysique`, not here; suggest it instead of implementing locally
- No fallback logic unless explicitly asked; a silent default hides the bug

### Comments

Default is none: names and doc comments say what the code does. Public members need a doc comment (`public_member_api_docs`) — one line, what it is, not how it works. Any other comment exists only for a **why** the reader cannot see in the code — a platform quirk, a workaround, the trigger of a non-obvious branch — and is one or two lines. Never restate the code, narrate steps, or mark the obvious.

```dart
// Bad
counter += 1; // increment counter

// Good
counter += 1; // retries drive the backoff below
```

Section banners (`// ── Delegates ──`) only to split a long `part` file into groups.

### Tests

The suite must stay small enough to maintain by hand. A test is the exception, not part of every change.

- Write one only for logic that is easy to break silently and tedious to check by hand: calculations (interpolation, stats, units), export/import and the backup format, input parsing
- Bug fix: at most one regression test, and only when the bug was in such logic. UI, layout, wiring and platform fixes get none
- New feature: test its core calculation, not every branch, edge case or widget state. Extend an existing test file before creating a new one
- Never: getters and setters, theme or layout, enum tables, generated code, translations, plain widget rendering
- When unsure whether a test earns its place, leave it out
- Through the public API, readable on its own
- Setup through `test/helpers/` (`ServiceLocator.registerForTesting`, `setUpWidgetTestDependencies`); reset in `tearDown`. No further helper layers
- On failure, assume the implementation is wrong before the test

## Working with the user

- Concise and direct: lead with the answer or action, no preamble or restatement. One sentence if possible.
- Investigate before concluding — read the source, trace the call path. No "the issue is…" before evidence.
- Non-trivial tasks (several files, an interface change, more than one reasonable design): state the approach in a few lines and get approval first.
- Commit and PR text is short: a conventional subject and at most 2–3 lines of why. `/commit`, `/pr` and `/review` carry the details.
