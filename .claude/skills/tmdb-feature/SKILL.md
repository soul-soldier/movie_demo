---
name: tmdb-feature
description: Implements or completes one TMDB feature of the movie app end to end (DTOs, API call, repository, Room cache where required, ViewModel, Compose screen, Navigation 3 key and bottom-navigation tab). Use whenever the user asks to build, add, finish or fix the Search, Movie detail, Genres, Popular people or Streaming providers feature, even if they only mention one layer of it.
argument-hint: "[search | detail | genres | people | providers]"
---

# Implement a TMDB feature

Feature: $ARGUMENTS (if empty, ask which one).

Read the feature's row in `AGENTS.md` first. It lists the endpoint and the required UI elements, which are what gets graded.

## Workflow

1. **Plan**: list the files you will create or change per layer and show the plan before editing. Reuse what exists
   (Ktor `HttpClient` setup, image URL helper, loading/error composables, paging pattern of another screen).
2. **Data layer**
   - DTOs with exactly the fields the UI needs plus paging fields, nullable where TMDB may omit them.
   - Endpoint in `TmdbApi`, domain model and mapping functions.
   - Repository interface, implementation and `@Binds` entry. Detail only: Room entity, DAO and the database-first logic.
3. **UI layer**
   - `…UiState` data class covering loading, content, error and, for paged screens, `isLoadingMore` and `canLoadMore`.
   - `@HiltViewModel`; paged features keep the page counter in the ViewModel.
   - Route + stateless screen, `@Preview` with sample data, all text in `strings.xml`.
   - Unit tests for the new ViewModel, repository (Ktor `MockEngine`) and mapping.
4. **Navigation**: typed `NavKey`, entry registered in `NavDisplay`. List features get a bottom-bar tab with icon and
   label. The detail screen receives only `movieId`.
5. **Verify**: run the new tests (`:app:testDebugUnitTest --tests "*<Feature>*"`), then `:app:assembleDebug` from the
   repository root, and fix errors. Then ask the user to try the feature in the
   emulator: typing fast, loading more pages, rotating, airplane mode.
6. **Report**: changed files, and anything the user must do themselves (e.g. put the key into `secrets.properties`).

## Feature notes

- Search: request on every keystroke, cancel the previous request, reset paging on a new query, de-duplicate ids.
- Detail: database first, network only on a miss, then store; backdrop, overview, rating as x/10 or progress bar.
- Genres: one request, whole list, no paging.
- People: `known_for_department` and `known_for` titles only when present; paging.
- Providers: `watch_region=DE`; visible "Provider data by JustWatch" text.