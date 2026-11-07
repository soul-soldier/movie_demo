---
paths:
  - "**/ui/**/*.kt"
  - "**/MainActivity.kt"
  - "**/res/values/strings.xml"
---

# UI layer (Compose + Navigation 3)

- Each screen is split into a route and a stateless screen:
  `SearchRoute(onMovieClick: (Int) -> Unit, viewModel: SearchViewModel = hiltViewModel())` collects the state and
  forwards events; `SearchScreen(uiState, onQueryChange, onLoadMore, onMovieClick)` only renders and has `@Preview`s.
- ViewModels are `@HiltViewModel`, keep `private val _uiState = MutableStateFlow(…)`, expose
  `val uiState = _uiState.asStateFlow()`, update with `_uiState.update { it.copy(…) }` and launch in `viewModelScope`.
- Search reacts to query changes with `flatMapLatest`/`collectLatest` (or cancels the previous `Job`) so an old response
  never overwrites a newer one. A blank query clears the list without a request.
- Navigation 3: keys are `@Serializable` and implement `NavKey` (`Search`, `Genres`, `People`, `Providers` as
  `data object`, `MovieDetail(val movieId: Int)`). The back stack (`rememberNavBackStack`) and `NavDisplay` live in one
  top-level composable called from `MainActivity`; screens receive lambdas, never the back stack.
  Add the saveable-state and ViewModel-store entry decorators so every entry gets its own ViewModel that is cleared
  when the entry is popped. Check the current Navigation 3 docs or the Android navigation skill for exact API names.
- Bottom bar: `NavigationBar` with four `NavigationBarItem`s (icon + label). `selected` comes from the current
  top-level destination; switching tabs doesn't pile up duplicate entries; the detail screen keeps the Search tab selected.
- `Scaffold` and apply its `innerPadding` to the content (edge-to-edge).
- Lists use `LazyVerticalGrid`/`LazyColumn` with `key = { it.id }`, plus a "Load more" button or automatic loading near
  the end with a progress indicator while the next page loads.
- Images use Coil `AsyncImage` with placeholder and error drawables, a `contentDescription` (title or name) and a fixed
  aspect ratio (posters 2:3, backdrops 16:9).
- Show the rating relative to the maximum, e.g. a string resource `%1$.1f/10` and/or
  `LinearProgressIndicator(progress = { voteAverage / 10f })`.
- Every screen handles loading, error (message + retry button) and empty states. No hard-coded UI text.
