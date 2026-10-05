Prepare a release: version bump, changelog, store changelogs, PR.

Usage: `/release` or `/release <X.Y.Z>` — version: `$ARGUMENTS` if given, else proposed in step 2.

## Step 1 — Check

1. `git fetch origin main`, `git switch main`, `git pull --ff-only` — stop on uncommitted changes to tracked files.
2. `[Unreleased]` in `CHANGELOG.md` is not empty — otherwise there is nothing to release; stop.
3. Read `version:` in `app/pubspec.yaml` (`X.Y.Z+<build>`) and the latest `## [X.Y.Z]` heading in `CHANGELOG.md`; they must match.

## Step 2 — Version

Propose the next version from `[Unreleased]` ([SemVer](https://semver.org)):

| `[Unreleased]` holds | Bump |
|---|---|
| `API Changes Warning ⚠️` | major |
| A feature or a new language under `Added Features and Improvements` | minor |
| Only fixes, translations, a Flutter or SDK upgrade, other changes | patch |

The build number always goes up by one. Show the proposal with the line that decided it and ask: this version, or a different one? Also ask whether the release gets an intro paragraph (a milestone, a thank-you) — never invent one.

## Step 3 — Prepare

Only after the version is confirmed. On a branch `release/prepare_vX.Y.Z`:

1. `app/pubspec.yaml`: `version: X.Y.Z+<build>`.
2. `CHANGELOG.md`:
   - Bring every `[Unreleased]` line in line with the CLAUDE.md Changelog section — short, for users, issue numbers kept.
   - Insert `## [X.Y.Z] - <today, YYYY-MM-DD>` directly below `## [Unreleased]`, so `[Unreleased]` stays as an empty heading on top; the intro paragraph, if any, follows the new heading.
   - Footer: `[Unreleased]` compares `vX.Y.Z...main`; add `[X.Y.Z]: …/compare/v<previous>...vX.Y.Z` below it.
3. `fastlane/metadata/android/{en-US,de}/changelogs/<build>3.txt` — the build number followed by the arm64 ABI digit `3` (build 48 → `483.txt`). Rules below.
4. From `app/`: `make generate`; `dart run quantumphysique:generate_changelog --check` must pass.
5. Show the new changelog section and both store texts; after approval commit everything as `chore: prepare vX.Y.Z` (via `/commit`) and open the PR (via `/pr`).

### Store changelogs

What F-Droid and the stores show next to the update — the version section boiled down to what users care about most.

- At most 500 characters per file, the store limit; aim well below
- Plain `- ` lines, no headings, no issue numbers, no links
- Order: features, then the Flutter upgrade, then `Improved translation`, then fixes
- Leave out `Minor improvements to the code base`, `Upgraded deps` and minor wording or styling changes; when space runs short, drop the least important fix before shortening the rest
- An intro paragraph replaces the list only when the list would not fit next to it, as for v1.0.0
- `de` says the same in German, in the style of the earlier files: `Verbesserte Übersetzung`, fixes as `… behoben`

```text
- Tapping a reminder now opens the add weight dialog straight away
- Fixed the launch screen always being white instead of following dark mode
```

```text
- Tippen auf eine Erinnerung öffnet jetzt direkt den Dialog zum Eintragen
- Immer weißer Startbildschirm behoben, er folgt jetzt dem Dunkelmodus
```

## Step 4 — After merge

Only once the PR is merged, and after asking: create the GitHub release, which tags `vX.Y.Z` and starts `flutter-release.yml`.

```bash
gh release create vX.Y.Z --target main --title "vX.Y.Z" --notes "<the X.Y.Z changelog section, without its heading>"
```

Never create or push a tag any other way.
