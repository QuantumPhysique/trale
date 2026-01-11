# What to do when a task/feature is complete

1. Run tests and linting locally (`flutter analyze`, `flutter test`).
2. Generate any code artifacts (`build_runner`), run formatting.
3. Commit and push to a `feature/*` branch: `git push -u origin feature/<name>`.
4. Create PR; include screenshots and test notes where applicable.
5. Wait for CodeRabbit/CI feedback (agent instructions suggest a 2-minute wait). Address any review comments with follow-up commits and push.
6. When approved, squash-merge the PR, pull updated `main`, and delete the feature branch.
7. Add release notes / update `CHANGELOG.md` and create a tag for release when appropriate.
8. For device-verified changes, attach screenshots and include device & OS info in PR description.
