Review the current branch against `main` (or the given target branch) and report. Read-only — do not edit files.

Usage: `/review` or `/review <target-branch>` — target: `$ARGUMENTS` if given, else `main`.

1. `git fetch origin <target>`, then `git diff origin/<target>...HEAD --stat` and the full diff.
2. Read every changed source file in full — the hunks alone hide context.

## Check

- **Correctness** — does the change do what the commits claim; edge cases; no silent fallbacks or defaults that hide a bug.
- **Conventions** — CLAUDE.md: explicit types, `QPTheme.of` / `Theme.of` only, strings through `context.l10n` with keys in `app_en.arb` and `app_de.arb` only, constants from `constants.dart`, settings added in the matching `preferences/` and `trale_notifier/` parts.
- **Comments** — any that restate the code, narrate steps, or explain how instead of why; the fix is deletion. Doc comments longer than what the member is.
- **Tests** — behaviour through the public API, readable on their own, setup via `test/helpers/`. Flag tests of getters, layout, enum tables or generated code, and tests that assert a removed feature is absent.
- **Unreleased** — shims, deprecations, migrations or compatibility code for anything that is only under `[Unreleased]` or on this branch. Released Hive fields and preference keys must still load.
- **Changelog** — a user-visible change without a line under `[Unreleased]`, a line for an internal change, or a stale `changelog.g.dart`.
- **Commits** — non-conventional subjects, bodies that narrate the diff, issue numbers in subjects.
- **Scope** — dead code, leftover debug output, unrelated drive-by edits, hand edits to Weblate-owned ARB files or `l10n-gen/`.
- **Placement** — app-agnostic code that belongs in `quantumphysique`.

## Output

Per file, one line per finding with `path:line`: **Issues** (block merge) first, then **Suggestions**. Skip what has nothing to say. Close with one line — merge, or what must change first.
