package com.example.moviedemo.ui.navigation

import androidx.annotation.StringRes
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Search
import androidx.compose.ui.graphics.vector.ImageVector
import com.example.moviedemo.R

/** The tabs of the bottom navigation bar, in display order. */
enum class TopLevelDestination(
    val key: TopLevelKey,
    @param:StringRes val labelRes: Int,
    val icon: ImageVector,
) {
    SEARCH(Search, R.string.tab_search, Icons.Filled.Search),
    GENRES(Genres, R.string.tab_genres, Icons.AutoMirrored.Filled.List),
    PEOPLE(People, R.string.tab_people, Icons.Filled.Person),
    PROVIDERS(Providers, R.string.tab_providers, Icons.Filled.PlayArrow),
}
