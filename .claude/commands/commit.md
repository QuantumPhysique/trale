Plan and create commits interactively, one at a time.

## Messages

[Conventional Commits](https://www.conventionalcommits.org/). PRs merge onto `main` with a merge commit, so every commit lands in the history as written — each one is a message a maintainer will read.

| Type | When |
|---|---|
| `feat` | New user-facing behaviour |
| `fix` | Bug fix |
| `refactor` | Restructuring, no behaviour change |
| `test` | Add or fix tests |
| `docs` | Docs, `CLAUDE.md`, README |
| `build` | Dependencies, `pubspec.yaml`, Gradle, Flutter upgrade |
| `ci` | Workflows |
| `chore` | Maintenance, release preparation |

- **Subject**: `type: what changed` — imperative, lower-case, no period, ≤ 72 characters. No issue numbers; they go in the PR body.
- **Body**: only when the why is not obvious from the subject, then 1–3 lines of why. No file lists, no restating the diff, no narrative of what was tried.

```text
fix: keep the height field focused while it is typed

The field was keyed on its value, so every keystroke remounted it and
dropped the focus.
```

A `CHANGELOG.md` line and the regenerated `changelog.g.dart` belong to the commit that makes the change, not to a commit of their own.

## Step 1 — Plan

1. `git branch --show-current` — on `main`, propose a `feat/<topic>` or `fix/<topic>` branch and ask before going on.
2. `git status --short` and `git diff HEAD` — untracked files are invisible to the diff; include them. Leave `.claude/`, `claude/` and local notes out.
3. Group the changes into atomic commits, one concern each, ordered so every commit leaves a working tree. Draft each message.
4. Present a numbered list — message plus the files it takes — and ask: go ahead, or adjust?

## Step 2 — Execute

Only after approval. For each commit:

1. `git add <file>…` — explicit files only. Never `git add .` or `-A`; `--patch` is interactive and does not work from a non-interactive shell. A file mixing two concerns goes with the commit it mostly belongs to, and the plan says so.
2. Show `git diff --cached --stat` and the message; ask "Commit N/total — commit?" (skip the question when the user said to run them all).
3. `git commit -m …`, confirm with `git log --oneline -1`, move on.

- Hook failure: fix the cause and retry — never `--no-verify`.
- On abort: `git reset HEAD`, stop.
