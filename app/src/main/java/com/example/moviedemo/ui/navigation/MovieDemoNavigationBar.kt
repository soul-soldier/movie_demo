package com.example.moviedemo.ui.navigation

import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import com.example.moviedemo.ui.theme.MovieDemoTheme

@Composable
fun MovieDemoNavigationBar(
    selectedKey: TopLevelKey,
    onTabClick: (TopLevelKey) -> Unit,
    modifier: Modifier = Modifier,
) {
    NavigationBar(modifier = modifier) {
        TopLevelDestination.entries.forEach { destination ->
            NavigationBarItem(
                selected = destination.key == selectedKey,
                onClick = { onTabClick(destination.key) },
                // The visible label already describes the tab, so the icon is decorative.
                icon = { Icon(imageVector = destination.icon, contentDescription = null) },
                label = { Text(text = stringResource(destination.labelRes)) },
            )
        }
    }
}

@Preview
@Composable
private fun MovieDemoNavigationBarPreview() {
    MovieDemoTheme {
        MovieDemoNavigationBar(selectedKey = Genres, onTabClick = {})
    }
}
