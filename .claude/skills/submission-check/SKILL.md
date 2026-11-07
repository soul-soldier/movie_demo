---
name: submission-check
description: Audits the movie app against the bonus-task pass criteria and grading (API key never exposed, app builds, required tech stack, feature requirements, code quality, README data, main branch) and reports what is missing. Use before committing to or pushing main, before the presentation, or whenever the user asks whether the app is done, ready or would pass.
---

# Submission check

Run every check, then report a table with check, status (✅ / ⚠️ / ❌), evidence and suggested fix.
Don't change anything until the user agrees.

## 1. API key (any failure fails the whole task)

Never open or search inside the secret files. These commands print only file names, never matching text:

- Tracked properties files: `git ls-files | grep -E '\.properties$'`. Allowed: `gradle.properties`,
  `gradle/wrapper/gradle-wrapper.properties`, `local.defaults.properties`.
- Ignore rules work: `git status --porcelain --ignored | grep -E '\.properties$'`. The secret files must show as `!!`.
- Never in history: `git log --all --name-only --format= | grep -E '\.properties$' | sort -u`
- Key-shaped strings anywhere in history (`-l` prints file names only):
  - `git grep -lwE '[0-9a-f]{32}' $(git rev-list --all)`
  - `git grep -lE 'eyJ[A-Za-z0-9_-]{20,}' $(git rev-list --all)`
  - `git grep -lE 'api_key=[A-Za-z0-9]' $(git rev-list --all)`

  For every hit, ask the user to inspect the file. A real key in the history means: revoke it on TMDB, create a new
  one and clean the history.
- The key is referenced only as `BuildConfig.TMDB_API_KEY` in the Ktor `defaultRequest` block, and no `Logging`
  plugin or other code logs request URLs or headers.

## 2. Build

From the repository root: `:app:assembleDebug` and `:app:testDebugUnitTest` succeed.

## 3. Minimum requirements

Kotlin only · exactly one `<activity>` in `AndroidManifest.xml` · screens are Composables · Hilt (`@HiltAndroidApp`,
`@AndroidEntryPoint`, `@HiltViewModel`) · Room · Ktor · coroutines between ViewModel, repository and data
sources · Navigation 3 and no `androidx.navigation:navigation-compose` dependency.

## 4. Features

Check each implemented feature against every point in its `AGENTS.md` row: Search (3P), Detail including Room cache and
id-only navigation (3P), one of Genres / People / Providers (3P), bottom navigation with four tabs and visible selection.

## 5. Quality (1P)

- Commented-out code: `git grep -nE '^\s*//\s*(val|var|fun|import|class|if|return|[A-Za-z_.]+\()' -- '*.kt'`,
  plus `/* … */` blocks that contain code.
- Leftovers: `git grep -nE 'TODO|println\(|Log\.[dviwe]\(' -- '*.kt'`
- Hard-coded UI strings in composables; screens without loading, error or empty state.

## 6. Organisation

- `README.md` contains name, Matrikelnummer and university email. Check presence only; never fill in values.
- `git branch --show-current` and `git status`: the final state must be committed on `main`.