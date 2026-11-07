---
paths:
  - "**/*.gradle.kts"
  - "**/libs.versions.toml"
  - "**/gradle.properties"
  - "**/local.defaults.properties"
---

# Gradle and dependencies

- Add every library and plugin to `gradle/libs.versions.toml` with an exact version (no `+`, no ranges)
  and reference it as `libs.…`. Don't bump AGP, Kotlin or the Compose BOM unless asked. Kotlin compiler plugins
  (Compose, serialization) use the project's Kotlin version.
- The project stays on AGP 8.13.2 with `compileSdk 36`. Pick library versions that support this; newer AndroidX
  releases such as `core` 1.19+ or `lifecycle` 2.11+ require AGP 9.1 and `compileSdk 37`. If Gradle reports an AAR
  metadata error, lower the library version instead of upgrading AGP.
- Use KSP for Hilt and Room, not kapt.
- All Ktor artifacts (`ktor-client-core`, `ktor-client-okhttp`, `ktor-client-content-negotiation`,
  `ktor-serialization-kotlinx-json`, `ktor-client-mock` for tests) share one version entry in the catalog.
- Secrets Gradle Plugin (`com.google.android.libraries.mapsplatform.secrets-gradle-plugin`) in the app module:

  ```kotlin
  secrets {
      propertiesFileName = "secrets.properties"
      defaultPropertiesFileName = "local.defaults.properties"
  }
  ```

  together with `buildFeatures { buildConfig = true }`. The plugin generates `BuildConfig.TMDB_API_KEY`. Never add the
  key with `buildConfigField` by hand or load the secrets file any other way.
- `local.defaults.properties` contains only `TMDB_API_KEY=DEFAULT_API_KEY` and is committed.
- After changing Gradle files, run `:app:assembleDebug` and fix sync or build errors before continuing.