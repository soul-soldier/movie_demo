package com.example.moviedemo.ui.navigation

import androidx.navigation3.runtime.NavKey
import kotlinx.serialization.Serializable

/** A destination that is shown as a tab in the bottom navigation bar. */
sealed interface TopLevelKey : NavKey

@Serializable
data object Search : TopLevelKey

@Serializable
data object Genres : TopLevelKey

@Serializable
data object People : TopLevelKey

@Serializable
data object Providers : TopLevelKey
