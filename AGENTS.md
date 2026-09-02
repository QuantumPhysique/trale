Read `CLAUDE.md` for all project conventions, setup, commands, and coding guidelines.

## Workflow prompts

`.claude/commands/` contains plain-markdown prompt files for common workflows. Claude Code loads them as slash commands; other tools use them by pasting the file content into the chat.

| File | Claude command | What it does |
|---|---|---|
| `commit.md` | `/commit` | Plan and create commits interactively, one at a time |
| `pr.md` | `/pr` | Open a pull request onto `main` |
| `review.md` | `/review` | Review the current branch against `main` |
