package com.jnrahme.androidsaintcharbel.features.story

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.jnrahme.androidsaintcharbel.core.audio.AudioPlayerController
import com.jnrahme.androidsaintcharbel.core.model.AudioTrack
import com.jnrahme.androidsaintcharbel.core.model.SaintStoryBook
import com.jnrahme.androidsaintcharbel.core.model.StoryBookPage
import com.jnrahme.androidsaintcharbel.core.model.StoryCatalog
import com.jnrahme.androidsaintcharbel.core.theme.AppPalette
import com.jnrahme.androidsaintcharbel.core.ui.BackIcon
import com.jnrahme.androidsaintcharbel.core.ui.ForwardIcon
import com.jnrahme.androidsaintcharbel.core.ui.PauseIcon
import com.jnrahme.androidsaintcharbel.core.ui.PillLabel
import com.jnrahme.androidsaintcharbel.core.ui.PlayIcon
import com.jnrahme.androidsaintcharbel.core.ui.SectionCard
import com.jnrahme.androidsaintcharbel.core.ui.StopIcon
import com.jnrahme.androidsaintcharbel.core.ui.StoryOpenIcon
import com.jnrahme.androidsaintcharbel.core.ui.StoryTag
import com.jnrahme.androidsaintcharbel.core.ui.symbolIcon
import kotlinx.coroutines.launch

@Composable
fun StoryLibraryScreen(onOpenStory: (String) -> Unit) {
    val stories = StoryCatalog.all
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        SectionCard {
            PillLabel("Storybook shelf", icon = symbolIcon("books.vertical.fill"))
            Text(
                text = "Choose a saint story and read it like a real book.",
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.displayMedium,
            )
            Text(
                text = "The library is designed around reusable story manifests, so Saint Charbel can be the first of many child-friendly saints without rebuilding the reader later.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
        }

        stories.forEach { story ->
            StoryBookShelfCard(story = story, onClick = { onOpenStory(story.id) })
        }

        SectionCard {
            Text("Built for young readers", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            StoryPrincipleRow("Simple first-use flow", "One story card opens one swipe reader, so children never have to decode a complex menu.")
            StoryPrincipleRow("Listening built in", "Narration starts from the current page and can keep moving through the book without extra setup.")
            StoryPrincipleRow("Ready for more saints", "Each future story only needs a new page manifest, artwork, and audio source.")
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun StoryBookShelfCard(
    story: SaintStoryBook,
    onClick: () -> Unit,
) {
    SectionCard(modifier = Modifier.clickable(onClick = onClick)) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(320.dp)
                .clip(RoundedCornerShape(24.dp)),
        ) {
            AsyncImage(
                model = story.pages.firstOrNull()?.imageUrl,
                contentDescription = story.title,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize(),
            )
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        Brush.verticalGradient(
                            colors = listOf(Color.Transparent, Color.Transparent, Color.Black.copy(alpha = 0.7f)),
                        ),
                    ),
            )
            Column(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(18.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    StoryTag(story.ageBand, AppPalette.Gold.copy(alpha = 0.22f), AppPalette.TextPrimary)
                    StoryTag("${story.pages.size} pages", Color.White.copy(alpha = 0.14f), AppPalette.TextPrimary)
                    StoryTag("${story.narratedPageCount} narrated", AppPalette.StoryBlue.copy(alpha = 0.34f), AppPalette.TextPrimary)
                }
                Text(
                    text = story.title,
                    color = Color.White,
                    style = MaterialTheme.typography.headlineLarge,
                )
                Text(
                    text = story.coverPrompt,
                    color = Color.White.copy(alpha = 0.9f),
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Medium),
                )
            }
        }

        Text(
            text = story.description,
            color = AppPalette.TextSecondary,
            style = MaterialTheme.typography.bodyLarge,
        )

        Row(verticalAlignment = Alignment.CenterVertically) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(StoryOpenIcon, contentDescription = null, tint = AppPalette.TextPrimary)
                Text("Open storybook", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
            }
            androidx.compose.foundation.layout.Spacer(modifier = Modifier.weight(1f))
            Icon(ForwardIcon, contentDescription = null, tint = AppPalette.Gold)
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun StoryReaderScreen(
    storyId: String,
    audioController: AudioPlayerController,
) {
    val story = remember(storyId) { StoryCatalog.all.firstOrNull { it.id == storyId } ?: StoryCatalog.saintCharbel }
    val pagerState = rememberPagerState(pageCount = { story.pages.size })
    val scope = rememberCoroutineScope()
    var followNarration by remember { mutableStateOf(false) }
    val currentPage = story.pages[pagerState.currentPage]
    val currentTrackId = audioController.currentTrack?.id
    val currentTrack = currentPage.audioTrack

    LaunchedEffect(currentTrackId, followNarration) {
        if (!followNarration || currentTrackId == null) return@LaunchedEffect
        val pageIndex = story.pages.indexOfFirst { it.audioTrack?.id == currentTrackId }
        if (pageIndex >= 0 && pageIndex != pagerState.currentPage) {
            pagerState.animateScrollToPage(pageIndex)
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(18.dp),
    ) {
        StoryReaderHeader(story = story, currentPage = pagerState.currentPage + 1)

        HorizontalPager(
            state = pagerState,
            modifier = Modifier.weight(1f),
        ) { pageIndex ->
            StoryBookPageCard(page = story.pages[pageIndex])
        }

        StoryReaderControls(
            currentPage = currentPage,
            title = narrationTitle(audioController, currentTrack, currentPage.isNarrated),
            icon = narrationIcon(audioController, currentTrack, currentPage.isNarrated),
            canGoBack = pagerState.currentPage > 0,
            canGoForward = pagerState.currentPage < story.pages.lastIndex,
            isNarratingCurrentPage = currentTrack != null && audioController.isCurrent(currentTrack),
            onBack = {
                if (pagerState.currentPage > 0) {
                    followNarration = false
                    scope.launch { pagerState.animateScrollToPage(pagerState.currentPage - 1) }
                }
            },
            onForward = {
                if (pagerState.currentPage < story.pages.lastIndex) {
                    followNarration = false
                    scope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) }
                }
            },
            onNarrate = {
                if (currentTrack == null) return@StoryReaderControls
                if (audioController.isCurrent(currentTrack)) {
                    audioController.togglePlayPause()
                } else {
                    followNarration = true
                    audioController.playQueue(story.pages.drop(pagerState.currentPage).mapNotNull { it.audioTrack })
                }
            },
            onStop = {
                followNarration = false
                audioController.stop()
            },
        )
    }
}

@Composable
private fun StoryReaderHeader(
    story: SaintStoryBook,
    currentPage: Int,
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            PillLabel(story.saintName, icon = symbolIcon("sparkles"))
            androidx.compose.foundation.layout.Spacer(modifier = Modifier.weight(1f))
            StoryTag(
                text = "Page $currentPage of ${story.pages.size}",
                fill = Color.White.copy(alpha = 0.12f),
                foreground = AppPalette.TextPrimary,
            )
        }
        Text(
            text = story.title,
            color = AppPalette.TextPrimary,
            style = MaterialTheme.typography.displayMedium,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
        LinearProgressIndicator(
            progress = { currentPage.toFloat() / story.pages.size.toFloat() },
            color = AppPalette.Gold,
            trackColor = Color.White.copy(alpha = 0.08f),
        )
    }
}

@Composable
private fun StoryBookPageCard(page: StoryBookPage) {
    val scrollState = rememberScrollState()

    Surface(
        modifier = Modifier
            .fillMaxSize()
            .padding(vertical = 4.dp),
        shape = RoundedCornerShape(34.dp),
        color = Color.Transparent,
        shadowElevation = 22.dp,
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .clip(RoundedCornerShape(34.dp))
                .background(
                    Brush.linearGradient(
                        colors = listOf(AppPalette.Paper, AppPalette.PaperShadow.copy(alpha = 0.82f)),
                    ),
                )
                .border(1.dp, Color.White.copy(alpha = 0.45f), RoundedCornerShape(34.dp))
                .verticalScroll(scrollState)
                .padding(22.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                StoryTag(
                    text = if (page.isNarrated) "${page.pageLabel}  •  audio" else page.pageLabel,
                    fill = Color.Black.copy(alpha = 0.12f),
                    foreground = AppPalette.Ink,
                )
                androidx.compose.foundation.layout.Spacer(modifier = Modifier.weight(1f))
                StoryTag(
                    text = if (page.isNarrated) "Narration ready" else "Image only",
                    fill = if (page.isNarrated) AppPalette.Gold.copy(alpha = 0.14f) else Color.Black.copy(alpha = 0.08f),
                    foreground = AppPalette.Ink.copy(alpha = if (page.isNarrated) 1f else 0.72f),
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                Text(text = page.title, color = AppPalette.Ink, style = MaterialTheme.typography.headlineLarge)
                Text(text = page.body, color = AppPalette.Ink.copy(alpha = 0.84f), style = MaterialTheme.typography.bodyLarge)
            }

            AsyncImage(
                model = page.imageUrl,
                contentDescription = page.title,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp)
                    .clip(RoundedCornerShape(28.dp))
                    .background(Color.Black.copy(alpha = 0.05f))
                    .border(1.dp, Color.White.copy(alpha = 0.65f), RoundedCornerShape(28.dp)),
            )

            StoryReflectionCard("Little prayer", page.prayer, AppPalette.Gold.copy(alpha = 0.18f), AppPalette.Ink)
            StoryReflectionCard("Heart moment", page.heart, Color.White.copy(alpha = 0.55f), AppPalette.Ink)

            Text(
                text = "Swipe sideways to turn pages. Scroll this page to keep reading while the artwork stays part of the story.",
                color = AppPalette.Ink.copy(alpha = 0.72f),
                style = MaterialTheme.typography.bodySmall,
            )
        }
    }
}

@Composable
private fun StoryReflectionCard(
    title: String,
    message: String,
    background: Color,
    foreground: Color,
) {
    Surface(shape = RoundedCornerShape(22.dp), color = background) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(text = title, color = foreground, style = MaterialTheme.typography.titleMedium)
            Text(text = message, color = foreground.copy(alpha = 0.86f), style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
private fun StoryReaderControls(
    currentPage: StoryBookPage,
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    canGoBack: Boolean,
    canGoForward: Boolean,
    isNarratingCurrentPage: Boolean,
    onBack: () -> Unit,
    onForward: () -> Unit,
    onNarrate: () -> Unit,
    onStop: () -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
            StoryRoundButton(BackIcon, canGoBack, onBack)

            Surface(
                modifier = Modifier
                    .weight(1f)
                    .clickable(enabled = currentPage.isNarrated, onClick = onNarrate),
                shape = RoundedCornerShape(22.dp),
                color = if (currentPage.isNarrated) AppPalette.Paper else Color.White.copy(alpha = 0.08f),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 16.dp),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(icon, contentDescription = null, tint = if (currentPage.isNarrated) AppPalette.Ink else AppPalette.TextSecondary)
                    androidx.compose.foundation.layout.Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = title,
                        color = if (currentPage.isNarrated) AppPalette.Ink else AppPalette.TextSecondary,
                        style = MaterialTheme.typography.titleMedium,
                    )
                }
            }

            StoryRoundButton(ForwardIcon, canGoForward, onForward)
        }

        if (isNarratingCurrentPage) {
            Row(
                modifier = Modifier
                    .align(Alignment.CenterHorizontally)
                    .clickable(onClick = onStop),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Icon(StopIcon, contentDescription = null, tint = AppPalette.TextPrimary.copy(alpha = 0.9f))
                Text(
                    text = "Stop narration",
                    color = AppPalette.TextPrimary.copy(alpha = 0.9f),
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold),
                )
            }
        }
    }
}

@Composable
private fun StoryRoundButton(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    enabled: Boolean,
    onClick: () -> Unit,
) {
    Box(
        modifier = Modifier
            .size(54.dp)
            .clip(CircleShape)
            .background(Color.White.copy(alpha = if (enabled) 0.12f else 0.06f))
            .clickable(enabled = enabled, onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, contentDescription = null, tint = if (enabled) AppPalette.TextPrimary else AppPalette.TextSecondary.copy(alpha = 0.55f))
    }
}

@Composable
private fun StoryPrincipleRow(title: String, detail: String) {
    Column(verticalArrangement = Arrangement.spacedBy(5.dp)) {
        Text(text = title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
        Text(text = detail, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
    }
}

private fun narrationTitle(controller: AudioPlayerController, track: AudioTrack?, isNarrated: Boolean): String {
    if (!isNarrated) return "Narration complete"
    if (track == null) return "Read to Me"
    return if (controller.isCurrent(track)) {
        if (controller.isPlaying) "Pause" else "Keep Listening"
    } else {
        "Read to Me"
    }
}

private fun narrationIcon(controller: AudioPlayerController, track: AudioTrack?, isNarrated: Boolean) =
    when {
        !isNarrated -> StopIcon
        track == null -> PlayIcon
        controller.isCurrent(track) && controller.isPlaying -> PauseIcon
        else -> PlayIcon
    }
