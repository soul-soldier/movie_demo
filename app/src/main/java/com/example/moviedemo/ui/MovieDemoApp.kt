package com.example.moviedemo.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.navigation3.rememberViewModelStoreNavEntryDecorator
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.runtime.rememberSaveableStateHolderNavEntryDecorator
import androidx.navigation3.ui.NavDisplay
import com.example.moviedemo.R
import com.example.moviedemo.ui.components.PlaceholderScreen
import com.example.moviedemo.ui.navigation.Genres
import com.example.moviedemo.ui.navigation.MovieDemoNavigationBar
import com.example.moviedemo.ui.navigation.People
import com.example.moviedemo.ui.navigation.Providers
import com.example.moviedemo.ui.navigation.Search
import com.example.moviedemo.ui.navigation.currentTopLevelKey
import com.example.moviedemo.ui.navigation.navigateToTopLevel

/** Top-level composable: owns the back stack and shows the current screen above the bottom bar. */
@Composable
fun MovieDemoApp() {
    val backStack = rememberNavBackStack(Search)

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            MovieDemoNavigationBar(
                selectedKey = backStack.currentTopLevelKey(),
                onTabClick = { key -> backStack.navigateToTopLevel(key) },
            )
        },
    ) { innerPadding ->
        NavDisplay(
            backStack = backStack,
            modifier = Modifier.padding(innerPadding),
            onBack = { backStack.removeLastOrNull() },
            // Keeps each entry's saveable state and gives it its own ViewModelStore,
            // which is cleared when the entry is popped.
            entryDecorators = listOf(
                rememberSaveableStateHolderNavEntryDecorator(),
                rememberViewModelStoreNavEntryDecorator(),
            ),
            entryProvider = entryProvider {
                entry<Search> { PlaceholderScreen(title = R.string.tab_search) }
                entry<Genres> { PlaceholderScreen(title = R.string.tab_genres) }
                entry<People> { PlaceholderScreen(title = R.string.tab_people) }
                entry<Providers> { PlaceholderScreen(title = R.string.tab_providers) }
            },
        )
    }
}
