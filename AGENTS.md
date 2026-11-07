# AGENTS.md

Shared instructions for every coding agent in this repository (Claude Code, GitHub Copilot, …).

## Project

Android app for the optional bonus task of the lecture *App-Programmierung WS26/27*: search movies and browse
genres, popular people and streaming providers using the TMDB API. It is a single-person assignment that the student
presents and explains to the lecturer, so prefer clear, conventional solutions the student can explain over clever ones.

- The repository root is also the Gradle root project; run all Gradle commands there. App module: `app/`.
- `.github/hooks/` contains the agent hooks, `.claude/` the Claude Code settings, rules and skills.
- `README.md` must contain the student's name, Matrikelnummer and university email. Never invent these; ask the user.

Build and check from the repository root (use `./gradlew` in Bash, `.\gradlew.bat` in PowerShell):
`:app:assembleDebug`, `:app:testDebugUnitTest`. Build after every non-trivial change and fix all errors before
reporting a task as done.

## Hard requirements (violating any of these fails the whole task)

1. **The TMDB API key must never be visible**: not in code, resources, tests, logs, commit messages, chat output or
   Git history.
   - The key lives only in `secrets.properties` in the repository root (git-ignored, maintained by the user) as `TMDB_API_KEY=…`.
     The committed `local.defaults.properties` holds the placeholder `TMDB_API_KEY=DEFAULT_API_KEY`.
   - The Secrets Gradle Plugin exposes it as `BuildConfig.TMDB_API_KEY`. Reference it in exactly one place
     (the `defaultRequest` block of the Ktor `HttpClient`).
   - Never read, create, edit, search or print `secrets.properties` or `local.properties`. Hooks and permission rules
     block this. If a step needs these files, stop and ask the user to do it. Never work around the block
     (scripts, other shells, encodings, wildcards).
   - Don't log request URLs or headers: TMDB v3 sends the key as the `api_key` query parameter. No Ktor `Logging`
     plugin.
   - Never use `git add -f`/`--force`. The secret files must stay git-ignored.
2. The app must not crash: network errors, empty results, missing images and rotation are handled.
3. Kotlin only. Exactly one Activity (`MainActivity`); every screen is a Composable.
4. Lecture architecture: UI layer (Composables + ViewModels with immutable UI state) and data layer
   (repositories + data sources). Coroutines and Flow between ViewModel, repository and data sources.
5. Hilt for dependency injection, Room for persistence, Ktor client with kotlinx.serialization for networking.
   Don't switch libraries without asking.
6. Navigation 3 (`androidx.navigation3`) with typed keys, **not** `NavHost`/`NavController` from
   `navigation-compose`. The lecture slides show the older API; the task requires Navigation 3.

## Features

Grading: Search 3P, Detail 3P, one further list feature 3P (only one of Genres/People/Providers is required),
quality 1P. Finish and polish one feature before starting the next, in this order.

| Feature   | Endpoint                                        | Must show / do |
|-----------|-------------------------------------------------|----------------|
| Search    | `GET search/movie?query=…&page=…`               | Text field; new request on every typed character (cancel the previous one); list or grid with `poster_path` and `title`; mechanism to load the next page; click opens the detail screen |
| Detail    | `GET movie/{movie_id}`                          | `backdrop_path`, `overview`, `vote_average` relative to the maximum (e.g. `7.3/10` or a progress bar). Read from Room first; only on a miss load from the network and store it |
| Genres    | `GET genre/movie/list`                          | List of genre `name`s (full list, no paging) |
| People    | `GET person/popular?page=…`                     | `profile_path`, `name`, plus `known_for_department` and `known_for` titles when present; paging |
| Providers | `GET watch/providers/movie?watch_region=DE`     | `logo_path`, `provider_name`; visible "Provider data by JustWatch" attribution |

- Base URL `https://api.themoviedb.org/3/`. Images: `https://image.tmdb.org/t/p/original` + relative path.
  Build image URLs in one helper and show a placeholder for `null` paths.
- Bottom navigation with four tabs (Search, Genres, People, Providers) and a clearly visible selected tab.
- Navigating to the detail screen passes **only** the movie id through a typed key, e.g.
  `@Serializable data class MovieDetail(val movieId: Int) : NavKey`.
- The detail ViewModel gets the id via `SavedStateHandle`, like `TodoDetailsViewModel` in the course code examples.
  If that example isn't available, ask the user for it instead of guessing. Hilt assisted injection is the fallback.

## Architecture conventions

- One repository per data type: `MovieRepository` (search, details with Room cache), `MovieGenreRepository`,
  `PopularPersonRepository`, `WatchProviderRepository`. Each has its own DTOs and maps them to domain models;
  ViewModels never see DTOs or Room entities.
- ViewModels expose `StateFlow<…UiState>` (immutable data class); the UI collects it with
  `collectAsStateWithLifecycle()`. State flows down, events go up as lambdas.
- Paged screens keep the current page number in the ViewModel and pass it to the repository; a new search query
  resets it to 1.
- Packages under the app's base package:
  `data/remote` (TmdbApi, dto), `data/local` (database, dao, entity), `data/repository`,
  `model` (domain models), `di` (Hilt modules), `ui/navigation`, `ui/search`, `ui/detail`, `ui/genres`,
  `ui/people`, `ui/providers`, `ui/components`, `ui/theme`.

## Code quality (graded)

- No commented-out code, leftover TODOs, unused code, imports or dependencies, and no `println`/debug logging.
- All UI text in `res/values/strings.xml`; meaningful `contentDescription`s; Material 3; every screen has loading,
  error (with retry) and empty states.
- Dependencies only through `gradle/libs.versions.toml` with exact versions, consumed from the module's
  `build.gradle.kts`. Ask before adding a library that isn't named here (Coil for images is fine).
- Code, identifiers and comments in English. Small functions; screens previewable with sample data.

## Tests and validation

- Add or update unit tests (`app/src/test`) for changed ViewModels, repositories and DTO/entity mapping. Follow the
  existing test utilities; otherwise use JUnit, `kotlinx-coroutines-test` (`runTest`, a test main dispatcher),
  hand-written fakes of the repository interfaces and Ktor's `MockEngine` for API/repository tests.
- Run the narrowest relevant check first, e.g. `:app:testDebugUnitTest --tests "*SearchViewModelTest"`, and finish
  with `:app:testDebugUnitTest` and `:app:assembleDebug`.

## Git

- The final code must be on `main`. Don't push, force-push or rewrite history unless the user asks.
- Small commits with clear messages.