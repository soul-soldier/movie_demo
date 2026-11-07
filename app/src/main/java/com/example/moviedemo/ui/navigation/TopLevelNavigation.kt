package com.example.moviedemo.ui.navigation

import androidx.navigation3.runtime.NavKey

/**
 * Switches to the tab of [key].
 *
 * [Search] is the start destination and always stays at the bottom of the back stack, so the stack is
 * either `[Search]` or `[Search, tab]`. Back from any tab returns to Search; back from Search leaves the app.
 */
fun MutableList<NavKey>.navigateToTopLevel(key: TopLevelKey) {
    if (lastOrNull() == key) return
    while (size > 1) {
        removeAt(lastIndex)
    }
    if (key != Search) {
        add(key)
    }
}

/** The tab that the screen on top of the back stack belongs to. */
fun List<NavKey>.currentTopLevelKey(): TopLevelKey =
    filterIsInstance<TopLevelKey>().lastOrNull() ?: Search
