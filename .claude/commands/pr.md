Open a pull request from the current branch into `main` (or the given target branch).

Usage: `/pr` or `/pr <target-branch>` — target: `$ARGUMENTS` if given, else `main`.

## Step 1 — Check

1. `git fetch origin <target>`.
2. `git branch --show-current` — on `main`: stop, propose a `feat/<topic>` or `fix/<topic>` branch first.
3. `git status --short` — stop on uncommitted changes to tracked files.
4. `gh pr view --json url` — if a PR already exists for this branch: `git push`, print its URL, done.
5. `git log origin/<target>..HEAD --oneline` and `git diff origin/<target>...HEAD --stat` — the scope. Every commit must be a conventional commit (`/commit`); reword before opening if one is not.
6. User-visible change without a `CHANGELOG.md` line under `[Unreleased]`: add it and regenerate. From `app/`: `dart run quantumphysique:generate_changelog --check` must pass.
7. Format, analyze and tests run once, here, on the finished branch: if they have not run on this exact tree, run `make format-check`, `make analyze` and `make test` from `app/` and fix what they report before opening.

## Step 2 — Open

Present target, title and body; after approval:

```bash
git push -u origin HEAD
gh pr create --base <target> --title "…" --body "…"
```

Print the URL.

## Format

**Title** — one conventional-commit line (`feat:`, `fix:`, …), ≤ 72 characters. With a single commit it is that commit's subject.

**Body** — readable in a minute:

```text
<why this change, 1–3 sentences>

**Changes**
- <one line per logical change — only when there is more than one>

Closes #<issue>
```

Removing or reworking something that never shipped (only under `[Unreleased]`, or on this branch): one line in the body saying so — no migration, no compatibility note beyond that.

No file lists, no test plan, no "this PR", no headers beyond Changes, nothing the diff already says.
