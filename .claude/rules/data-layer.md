---
paths:
  - "**/data/**/*.kt"
  - "**/di/**/*.kt"
  - "**/model/**/*.kt"
  - "**/AndroidManifest.xml"
---

# Data layer

- Hilt provides one Ktor `HttpClient` (OkHttp engine) as `@Singleton`, configured with
  `expectSuccess = true` (HTTP errors throw), `ContentNegotiation { json(Json { ignoreUnknownKeys = true }) }` and

  ```kotlin
  defaultRequest {
      url("https://api.themoviedb.org/3/")
      url { parameters.append("api_key", BuildConfig.TMDB_API_KEY) }
  }
  ```

  This block is the only code that touches the key. No `Logging` plugin. The manifest declares the `INTERNET`
  permission.
- `TmdbApi` is a class that receives the `HttpClient` and has one `suspend` function per endpoint, using relative paths
  without a leading slash, e.g. `client.get("search/movie") { parameter("query", query); parameter("page", page) }
  .body<MoviePageDto>()`.
- DTOs are `@Serializable` with `@SerialName("snake_case")`. Every field TMDB may omit or send as `null` is nullable
  (`poster_path`, `backdrop_path`, `profile_path`, `logo_path`, `overview`, `known_for_department`, `release_date`, …).
  `known_for` mixes movies (`title`) and TV shows (`name`); use whichever is present.
- Paged responses contain `page`, `results`, `total_pages`; more pages exist while `page < total_pages`.
  TMDB can return the same id on two pages, so de-duplicate by id when appending.
- Mapping lives in extension functions next to the DTO or entity: `toDomain()`, `toEntity()`.
  Repositories return domain models only.
- Room stores movie details: entity, DAO with `@Upsert` and `suspend fun getById(id: Int): MovieDetailEntity?`,
  list fields such as genre names via a `TypeConverter`. Database and DAO are Hilt singletons.
- `MovieRepository.getMovieDetail(id)`: database first; on a miss fetch from the API, store it, return it.
- Repositories catch network (`IOException`), HTTP (`ResponseException`) and serialization exceptions and return a failure (`Result` or a sealed type) so the
  UI can show an error with retry. Always rethrow `CancellationException` (plain `runCatching` swallows it).
- Repositories are interfaces with an implementation bound via `@Binds`, so ViewModels can be tested with fakes.