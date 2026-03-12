package com.jnrahme.androidsaintcharbel.features.home

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.jnrahme.androidsaintcharbel.core.health.AppHealthModel
import com.jnrahme.androidsaintcharbel.core.health.AppHealthState
import com.jnrahme.androidsaintcharbel.core.theme.AppPalette
import com.jnrahme.androidsaintcharbel.core.ui.ActionLabelRow
import com.jnrahme.androidsaintcharbel.core.ui.CheckIcon
import com.jnrahme.androidsaintcharbel.core.ui.PillLabel
import com.jnrahme.androidsaintcharbel.core.ui.RefreshIcon
import com.jnrahme.androidsaintcharbel.core.ui.SectionCard
import com.jnrahme.androidsaintcharbel.core.ui.StatTile
import com.jnrahme.androidsaintcharbel.core.ui.StoryOpenIcon
import com.jnrahme.androidsaintcharbel.core.ui.TriangleIcon
import com.jnrahme.androidsaintcharbel.core.ui.symbolIcon
import com.jnrahme.androidsaintcharbel.features.story.StoryBookShelfCard
import kotlinx.coroutines.launch
import java.time.ZoneId
import java.time.format.DateTimeFormatter

@Composable
fun HomeScreen(
    onOpenStory: () -> Unit,
    onOpenStoryLibrary: () -> Unit,
    onOpenRosary: () -> Unit,
    onOpenRecommendedSet: () -> Unit,
) {
    val recommendedSet = com.jnrahme.androidsaintcharbel.core.model.RosarySet.recommended()
    val healthModel = remember { AppHealthModel() }
    val scope = rememberCoroutineScope()
    val context = LocalContext.current

    LaunchedEffect(Unit) {
        healthModel.refreshIfNeeded()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        SectionCard {
            PillLabel("marsharbel companion", icon = symbolIcon("dot.radiowaves.left.and.right"))

            Text(
                text = "Saint Charbel for prayer, story, and daily stillness.",
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.displayMedium,
            )

            Text(
                text = "This Android app complements marsharbel.com with a focused native experience: a swipeable Saint Charbel storybook, guided Rosary mystery paths, and core prayer texts in one place.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                QuickActionButton(
                    title = "Read the Story",
                    subtitle = "Swipe picture book",
                    symbol = "book.closed.fill",
                    onClick = onOpenStory,
                    modifier = Modifier.weight(1f),
                )
                QuickActionButton(
                    title = "Pray the Rosary",
                    subtitle = recommendedSet.schedule,
                    symbol = recommendedSet.symbol,
                    onClick = onOpenRosary,
                    modifier = Modifier.weight(1f),
                )
            }
        }

        SectionCard {
            Text(
                text = "Saint Charbel at a glance",
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.titleLarge,
            )

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                StatTile("Born in Bekaa Kafra", "1828", Modifier.weight(1f))
                StatTile("Final Mass", "1898", Modifier.weight(1f))
                StatTile("Canonized", "1977", Modifier.weight(1f))
            }
        }

        SectionCard(
            modifier = Modifier.clickable(onClick = onOpenRecommendedSet),
        ) {
            PillLabel("Today's recommended mysteries", icon = symbolIcon(recommendedSet.symbol))
            Text(
                text = recommendedSet.title,
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = recommendedSet.summary,
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = recommendedSet.schedule,
                    color = AppPalette.accent(recommendedSet),
                    style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Medium),
                )
                androidx.compose.foundation.layout.Spacer(modifier = Modifier.weight(1f))
                ActionLabelRow(
                    title = "Open set",
                    icon = TriangleIcon,
                    tint = AppPalette.TextPrimary,
                )
            }
        }

        SectionCard {
            Text(
                text = "Storybook",
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.titleLarge,
            )
            Text(
                text = "Open the Saint Charbel story like a real book and let the narration guide the page turns.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
        }

        StoryBookShelfCard(
            story = com.jnrahme.androidsaintcharbel.core.model.StoryCatalog.saintCharbel,
            onClick = onOpenStory,
        )

        SectionCard {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    PillLabel("Service status", icon = healthModel.overallState.icon())
                    Text(
                        text = "App health check",
                        color = AppPalette.TextPrimary,
                        style = MaterialTheme.typography.titleLarge,
                    )
                    Text(
                        text = "Checks the remote website, story artwork, narration, and rosary audio that this app depends on.",
                        color = AppPalette.TextSecondary,
                        style = MaterialTheme.typography.bodyLarge,
                    )
                }

                Icon(
                    imageVector = RefreshIcon,
                    contentDescription = "Refresh health",
                    tint = AppPalette.Gold,
                    modifier = Modifier
                        .clip(CircleShape)
                        .clickable {
                            scope.launch { healthModel.refresh() }
                        }
                        .padding(8.dp),
                )
            }

            healthModel.results.forEach { result ->
                HealthStatusRow(
                    title = result.service.title,
                    detail = result.service.detail,
                    summary = result.summary,
                    state = result.state,
                )
            }

            Text(
                text = healthModel.lastChecked?.atZone(ZoneId.systemDefault())
                    ?.format(DateTimeFormatter.ofPattern("h:mm a"))
                    ?.let { "Last checked $it" }
                    ?: "Awaiting first check",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodySmall,
            )
        }

        SectionCard {
            Text(
                text = "Connected to the website",
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.titleLarge,
            )
            Text(
                text = "The content in this app is aligned to the existing Saint Charbel website, and rosary audio streams directly from the same media library so updates can stay centralized.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
            ActionLabelRow(
                title = "Open marsharbel.com",
                icon = StoryOpenIcon,
                tint = AppPalette.TextPrimary,
                modifier = Modifier
                    .clip(RoundedCornerShape(18.dp))
                    .background(AppPalette.Gold.copy(alpha = 0.14f))
                    .clickable {
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://marsharbel.com")))
                    }
                    .padding(horizontal = 16.dp, vertical = 14.dp),
            )
        }
    }
}

@Composable
private fun QuickActionButton(
    title: String,
    subtitle: String,
    symbol: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    SectionCard(
        modifier = modifier.clickable(onClick = onClick),
    ) {
        Icon(symbolIcon(symbol), contentDescription = null, tint = AppPalette.Gold)
        Text(
            text = title,
            color = AppPalette.TextPrimary,
            style = MaterialTheme.typography.titleMedium,
        )
        Text(
            text = subtitle,
            color = AppPalette.TextSecondary,
            style = MaterialTheme.typography.bodyMedium,
        )
    }
}

@Composable
private fun HealthStatusRow(
    title: String,
    detail: String,
    summary: String,
    state: AppHealthState,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.05f))
            .padding(14.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Icon(
            imageVector = state.icon(),
            contentDescription = null,
            tint = state.color(),
            modifier = Modifier.padding(top = 2.dp),
        )
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(text = title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
            Text(text = detail, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodySmall)
            Text(text = summary, color = state.color(), style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold))
        }
    }
}

private fun AppHealthState.icon() = when (this) {
    AppHealthState.CHECKING -> RefreshIcon
    AppHealthState.HEALTHY -> CheckIcon
    AppHealthState.DEGRADED,
    AppHealthState.UNAVAILABLE,
    -> TriangleIcon
}

private fun AppHealthState.color() = when (this) {
    AppHealthState.CHECKING -> AppPalette.Gold
    AppHealthState.HEALTHY -> AppPalette.Olive
    AppHealthState.DEGRADED -> AppPalette.Gold
    AppHealthState.UNAVAILABLE -> AppPalette.Rose
}
