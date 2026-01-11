T2 Database refactor implemented (partial)

- Branch: feature/db-sqlite-refactor
- Commit: 0ab44ca (feat(db): bump Drift schemaVersion to 2 to enable migration (remove target_weight))
- Files: `app/lib/core/db/app_database.dart` (tables and migrations), `app/test/db/app_database_test.dart` (CRUD + migration unit test)
- Changes: Drift schema matches `.serena/memories/db_schema_refactor.md` (check_in, workout_tag, workout, workout_workout_tag, check_in_color, check_in_photo). Added idempotent migration helper `removeLegacyTargetWeightIfPresentFn` and bumped schemaVersion to 2 so onUpgrade will run for existing installs.
- Tests: `flutter test test/db/app_database_test.dart` passed in local environment.
- Notes: decided to keep photos as file paths (no BLOBs). Migration is safe: copies `measurements` -> `measurements_new` without `target_weight` if present, then renames.
- Next steps: create PR, run full CI, add integration tests (if needed), update Linear T2 issue comments and mark In Progress / Done depending on review.
