package com.jnrahme.androidsaintcharbel.app

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.jnrahme.androidsaintcharbel.core.audio.rememberAudioPlayerController
import com.jnrahme.androidsaintcharbel.core.model.RosarySet
import com.jnrahme.androidsaintcharbel.core.model.SaintCharbelLibrary
import com.jnrahme.androidsaintcharbel.core.model.StoryCatalog
import com.jnrahme.androidsaintcharbel.core.theme.AppPalette
import com.jnrahme.androidsaintcharbel.core.ui.AppBackground
import com.jnrahme.androidsaintcharbel.core.ui.BackIcon
import com.jnrahme.androidsaintcharbel.core.ui.MiniPlayerBar
import com.jnrahme.androidsaintcharbel.core.ui.symbolIcon
import com.jnrahme.androidsaintcharbel.features.home.HomeScreen
import com.jnrahme.androidsaintcharbel.features.rosary.PrayerReferenceScreen
import com.jnrahme.androidsaintcharbel.features.rosary.RosaryHubScreen
import com.jnrahme.androidsaintcharbel.features.rosary.RosaryMysteryScreen
import com.jnrahme.androidsaintcharbel.features.rosary.RosarySetScreen
import com.jnrahme.androidsaintcharbel.features.story.StoryLibraryScreen
import com.jnrahme.androidsaintcharbel.features.story.StoryReaderScreen

private object Routes {
    const val HOME = "home"
    const val STORY_LIBRARY = "story"
    const val STORY_READER = "story/{storyId}"
    const val ROSARY_HUB = "rosary"
    const val ROSARY_SET = "rosary-set/{setId}"
    const val ROSARY_MYSTERY = "rosary-mystery/{mysteryKey}"
    const val PRAYERS = "prayers"

    fun storyReader(storyId: String) = "story/$storyId"
    fun rosarySet(set: RosarySet) = "rosary-set/${set.name.lowercase()}"
    fun rosaryMystery(key: String) = "rosary-mystery/$key"
}

private enum class TopLevelDestination(
    val route: String,
    val label: String,
    val symbol: String,
) {
    HOME(Routes.HOME, "Home", "house.fill"),
    STORY(Routes.STORY_LIBRARY, "Story", "book.closed.fill"),
    ROSARY(Routes.ROSARY_HUB, "Rosary", "sparkles"),
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SaintCharbelAndroidApp() {
    val navController = rememberNavController()
    val audioController = rememberAudioPlayerController()

    DisposableEffect(audioController) {
        onDispose { audioController.release() }
    }

    val backStackEntry by navController.currentBackStackEntryAsState()
    val destination = backStackEntry?.destination
    val currentRoute = destination?.route.orEmpty()
    val topLevelSelection = when {
        currentRoute.startsWith("story") -> TopLevelDestination.STORY
        currentRoute.startsWith("rosary") || currentRoute == Routes.PRAYERS -> TopLevelDestination.ROSARY
        else -> TopLevelDestination.HOME
    }
    val showBack = currentRoute !in setOf(Routes.HOME, Routes.STORY_LIBRARY, Routes.ROSARY_HUB)
    val title = when {
        currentRoute == Routes.HOME -> "Saint Charbel"
        currentRoute == Routes.STORY_LIBRARY -> "Story"
        currentRoute.startsWith("story/") -> StoryCatalog.saintCharbel.saintName
        currentRoute == Routes.ROSARY_HUB -> "Rosary"
        currentRoute.startsWith("rosary-set/") -> {
            val setId = backStackEntry?.arguments?.getString("setId").orEmpty()
            RosarySet.valueOf(setId.uppercase()).title
        }
        currentRoute.startsWith("rosary-mystery/") -> {
            val key = backStackEntry?.arguments?.getString("mysteryKey").orEmpty()
            SaintCharbelLibrary.mysteries(RosarySet.JOYFUL)
                .plus(SaintCharbelLibrary.mysteries(RosarySet.LUMINOUS))
                .plus(SaintCharbelLibrary.mysteries(RosarySet.SORROWFUL))
                .plus(SaintCharbelLibrary.mysteries(RosarySet.GLORIOUS))
                .firstOrNull { it.key == key }
                ?.title
                ?: "Rosary"
        }
        currentRoute == Routes.PRAYERS -> "Prayers"
        else -> "Saint Charbel"
    }

    AppBackground {
        Scaffold(
            modifier = Modifier.fillMaxSize(),
            containerColor = Color.Transparent,
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            text = title,
                            color = AppPalette.TextPrimary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                    },
                    navigationIcon = {
                        if (showBack) {
                            androidx.compose.material3.IconButton(onClick = { navController.navigateUp() }) {
                                Icon(BackIcon, contentDescription = "Back", tint = AppPalette.Gold)
                            }
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = AppPalette.ChromeBackground.copy(alpha = 0.98f),
                        titleContentColor = AppPalette.TextPrimary,
                    ),
                )
            },
            bottomBar = {
                Column {
                    if (audioController.hasActiveTrack) {
                        MiniPlayerBar(
                            controller = audioController,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        )
                    }

                    NavigationBar(
                        containerColor = AppPalette.ChromeBackground.copy(alpha = 0.98f),
                    ) {
                        TopLevelDestination.entries.forEach { item ->
                            val selected = destination?.hierarchy?.any { it.route == item.route } == true ||
                                (item == topLevelSelection && currentRoute !in TopLevelDestination.entries.map { it.route })
                            NavigationBarItem(
                                selected = selected,
                                onClick = {
                                    navController.navigate(item.route) {
                                        popUpTo(navController.graph.startDestinationId) {
                                            saveState = true
                                        }
                                        launchSingleTop = true
                                        restoreState = true
                                    }
                                },
                                icon = {
                                    Icon(
                                        imageVector = symbolIcon(item.symbol),
                                        contentDescription = item.label,
                                    )
                                },
                                label = { Text(item.label) },
                                colors = androidx.compose.material3.NavigationBarItemDefaults.colors(
                                    selectedIconColor = AppPalette.Gold,
                                    selectedTextColor = AppPalette.Gold,
                                    indicatorColor = Color.Transparent,
                                    unselectedIconColor = AppPalette.TabInactive,
                                    unselectedTextColor = AppPalette.TabInactive,
                                ),
                            )
                        }
                    }
                }
            },
        ) { innerPadding ->
            NavHost(
                navController = navController,
                startDestination = Routes.HOME,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
            ) {
                composable(Routes.HOME) {
                    HomeScreen(
                        onOpenStory = { navController.navigate(Routes.storyReader(StoryCatalog.saintCharbel.id)) },
                        onOpenStoryLibrary = { navController.navigate(Routes.STORY_LIBRARY) },
                        onOpenRosary = { navController.navigate(Routes.ROSARY_HUB) },
                        onOpenRecommendedSet = { navController.navigate(Routes.rosarySet(RosarySet.recommended())) },
                    )
                }
                composable(Routes.STORY_LIBRARY) {
                    StoryLibraryScreen(
                        onOpenStory = { navController.navigate(Routes.storyReader(it)) },
                    )
                }
                composable(
                    route = Routes.STORY_READER,
                    arguments = listOf(navArgument("storyId") { type = NavType.StringType }),
                ) { entry ->
                    StoryReaderScreen(
                        storyId = entry.arguments?.getString("storyId").orEmpty(),
                        audioController = audioController,
                    )
                }
                composable(Routes.ROSARY_HUB) {
                    RosaryHubScreen(
                        onOpenSet = { navController.navigate(Routes.rosarySet(it)) },
                        onOpenPrayers = { navController.navigate(Routes.PRAYERS) },
                    )
                }
                composable(
                    route = Routes.ROSARY_SET,
                    arguments = listOf(navArgument("setId") { type = NavType.StringType }),
                ) { entry ->
                    val set = RosarySet.valueOf(entry.arguments?.getString("setId").orEmpty().uppercase())
                    RosarySetScreen(
                        set = set,
                        onOpenMystery = { navController.navigate(Routes.rosaryMystery(it)) },
                    )
                }
                composable(
                    route = Routes.ROSARY_MYSTERY,
                    arguments = listOf(navArgument("mysteryKey") { type = NavType.StringType }),
                ) { entry ->
                    RosaryMysteryScreen(
                        mysteryKey = entry.arguments?.getString("mysteryKey").orEmpty(),
                        audioController = audioController,
                    )
                }
                composable(Routes.PRAYERS) {
                    PrayerReferenceScreen()
                }
            }
        }
    }
}
