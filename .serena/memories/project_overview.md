# Project Overview: Trale (local copy: trale-plus)

- Purpose: A privacy-respecting body-weight diary app (Flutter) focused on tracking weight, measurements, and progress. The workspace contains an autonomous agent plan (Agent_Instructions.md) to refactor into a more comprehensive fitness journal (SQLite/Drift, camera integration, emotional tracking, calendar UI).

- Tech stack:
  - Flutter (Dart 3, null-safety), Android & iOS targets
  - State management: Provider
  - Storage: currently Hive (hive_ce, hive_ce_flutter); planned Drift migration documented in Agent_Instructions.md
  - Common packages: intl, path_provider, flutter_lints, flutter_localizations
  - CI: GitHub Actions (see .github/workflows)

- Key files & folders:
  - `app/pubspec.yaml` (dependencies, environment)
  - `Agent_Instructions.md` (project-level refactor mission & agent steps)
  - `lib/` (app source; core, pages, widgets, l10n)
  - `android/`, `ios/` (platform config & build files)
  - `fastlane/` (release metadata)
  - `.github/workflows/` (CI build/release pipelines)

- Quick notes:
  - The repo currently uses `flutter_lints` and a strict `analysis_options.yaml`.
  - Integration-test flow is specified in `Agent_Instructions.md` (device testing via `adb`).
