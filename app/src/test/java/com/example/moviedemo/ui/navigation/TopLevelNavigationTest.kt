package com.example.moviedemo.ui.navigation

import androidx.navigation3.runtime.NavKey
import org.junit.Assert.assertEquals
import org.junit.Test

class TopLevelNavigationTest {

    @Test
    fun `selecting a tab from Search puts it above Search`() {
        val backStack = mutableListOf<NavKey>(Search)

        backStack.navigateToTopLevel(Genres)

        assertEquals(listOf(Search, Genres), backStack)
    }

    @Test
    fun `switching tabs replaces the tab above Search`() {
        val backStack = mutableListOf<NavKey>(Search, Genres)

        backStack.navigateToTopLevel(People)

        assertEquals(listOf(Search, People), backStack)
    }

    @Test
    fun `reselecting the current tab keeps the back stack`() {
        val backStack = mutableListOf<NavKey>(Search, Providers)

        backStack.navigateToTopLevel(Providers)

        assertEquals(listOf(Search, Providers), backStack)
    }

    @Test
    fun `selecting Search pops back to Search`() {
        val backStack = mutableListOf<NavKey>(Search, People)

        backStack.navigateToTopLevel(Search)

        assertEquals(listOf(Search), backStack)
    }

    @Test
    fun `current top level key is the last tab in the back stack`() {
        assertEquals(Search, listOf<NavKey>(Search).currentTopLevelKey())
        assertEquals(Providers, listOf<NavKey>(Search, Providers).currentTopLevelKey())
    }
}
