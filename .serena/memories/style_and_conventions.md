# Style & Conventions

- Analysis & Lints:
  - Uses `flutter_lints` with a project `analysis_options.yaml` that enforces: no implicit casts/dynamic, `always_specify_types`, `prefer_single_quotes`, `prefer_final_locals`, and many Flutter best-practice rules.

- Formatting:
  - Use `dart format` (pre-commit hooks not present by default).

- Testing:
  - Unit/widget tests: `flutter_test` (see `test/`)
  - Integration tests: `integration_test` (Agent_Instructions outlines device-based integration tests)

- Branch & PR etiquette:
  - Feature branches follow `feature/<name>` convention, create PR against `main`, run CI, address CodeRabbit feedback, merge via squash.

- Documentation:
  - Add screenshots to `screenshots/` as verification artifacts as specified in Agent_Instructions.
