@AGENTS.md

## Claude Code specifics

- Start Claude Code in the repository root (`C:\Code\movie_demo`). `.claude/settings.json` with the permission rules
  and hooks is only loaded from the directory Claude Code starts in.
- Secret guard: `permissions.deny` in `.claude/settings.json` plus a `PreToolUse` hook
  (`.github/hooks/scripts/block-local-properties.ps1`, shared with Copilot) block `secrets.properties` and
  `local.properties`. When a call is denied, tell the user what you need instead of retrying another way.
  The hook also blocks shell commands that merely name these files, so leave the names out of commit messages.
- Path-specific rules in `.claude/rules/` load automatically when you touch Gradle files, the data layer or the UI layer.
- Skills: `/tmdb-feature <feature>` implements one feature end to end; `/submission-check` audits the pass criteria
  before committing to `main` or presenting.
- For a new feature, plan first and show the plan; then implement it in small steps and build after each step.
- If Android skills from `android/skills` are installed, prefer them for Android-specific APIs (e.g. Navigation 3,
  edge-to-edge) over memory.
