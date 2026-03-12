package com.jnrahme.androidsaintcharbel.features.rosary

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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.jnrahme.androidsaintcharbel.core.audio.AudioPlayerController
import com.jnrahme.androidsaintcharbel.core.model.PrayerText
import com.jnrahme.androidsaintcharbel.core.model.RosaryMystery
import com.jnrahme.androidsaintcharbel.core.model.RosarySet
import com.jnrahme.androidsaintcharbel.core.model.SaintCharbelLibrary
import com.jnrahme.androidsaintcharbel.core.theme.AppPalette
import com.jnrahme.androidsaintcharbel.core.ui.ActionLabelRow
import com.jnrahme.androidsaintcharbel.core.ui.PillLabel
import com.jnrahme.androidsaintcharbel.core.ui.PlayIcon
import com.jnrahme.androidsaintcharbel.core.ui.SectionCard
import com.jnrahme.androidsaintcharbel.core.ui.StopIcon
import com.jnrahme.androidsaintcharbel.core.ui.symbolIcon

@Composable
fun RosaryHubScreen(
    onOpenSet: (RosarySet) -> Unit,
    onOpenPrayers: () -> Unit,
) {
    val recommendedSet = RosarySet.recommended()
    val orderedSets = listOf(recommendedSet) + RosarySet.entries.filter { it != recommendedSet }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        SectionCard {
            PillLabel("Rosary companion", icon = symbolIcon("sparkles"))
            Text("A calm guided path for daily Rosary prayer.", color = AppPalette.TextPrimary, style = MaterialTheme.typography.displayMedium)
            Text(
                "Use the prayer flow, choose a mystery set, and optionally stream the guided audio already hosted on marsharbel.com.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
            GradientRosaryButton(
                title = "Start with today's set",
                subtitle = "${recommendedSet.title} • ${recommendedSet.schedule}",
                set = recommendedSet,
                onClick = { onOpenSet(recommendedSet) },
            )
        }

        SectionCard {
            Text("Prayer flow", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            SaintCharbelLibrary.rosarySequence.forEachIndexed { index, item ->
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("${index + 1}", color = AppPalette.Gold, style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold))
                    Text(item, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
                }
            }
        }

        SectionCard {
            Text("Choose your pace", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            SaintCharbelLibrary.coachPlans.forEach { plan ->
                Surface(shape = RoundedCornerShape(18.dp), color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.05f)) {
                    Column(
                        modifier = Modifier.fillMaxWidth().padding(14.dp),
                        verticalArrangement = Arrangement.spacedBy(6.dp),
                    ) {
                        Text(
                            "${plan.minutes} minutes • ${plan.decades} ${if (plan.decades == 1) "decade" else "decades"}",
                            color = AppPalette.TextPrimary,
                            style = MaterialTheme.typography.titleMedium,
                        )
                        Text(plan.summary, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }

        SectionCard(modifier = Modifier.clickable(onClick = onOpenPrayers)) {
            Text("Prayer reference", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            Text(
                "Keep the Apostles' Creed, Hail Mary, Glory Be, Fatima Prayer, Hail Holy Queen, and the concluding prayer close at hand.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
            ActionLabelRow("Open prayer texts", symbolIcon("text.book.closed"), AppPalette.Gold)
        }

        orderedSets.forEach { set ->
            RosarySetCard(set = set, onClick = { onOpenSet(set) })
        }
    }
}

@Composable
fun RosarySetScreen(
    set: RosarySet,
    onOpenMystery: (String) -> Unit,
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        SectionCard {
            PillLabel(set.schedule, icon = symbolIcon(set.symbol))
            Text(set.title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.displayMedium)
            Text(set.summary, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyLarge)
        }

        SaintCharbelLibrary.mysteries(set).forEach { mystery ->
            SectionCard(modifier = Modifier.clickable { onOpenMystery(mystery.key) }) {
                Text("Mystery ${mystery.number}", color = AppPalette.accent(set), style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold))
                Text(mystery.title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
                Text(mystery.fruit, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
                Text(mystery.steps.first(), color = AppPalette.TextPrimary.copy(alpha = 0.92f), style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Medium))
            }
        }
    }
}

@Composable
fun RosaryMysteryScreen(
    mysteryKey: String,
    audioController: AudioPlayerController,
) {
    val mystery = remember(mysteryKey) {
        RosarySet.entries.flatMap { SaintCharbelLibrary.mysteries(it) }.first { it.key == mysteryKey }
    }
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        SectionCard {
            PillLabel(mystery.day, icon = symbolIcon(mystery.set.symbol))
            Text(mystery.title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.displayMedium)
            Text("Fruit: ${mystery.fruit}", color = AppPalette.accent(mystery.set), style = MaterialTheme.typography.titleMedium)
            Text(
                "Stream the guided meditation from the website's audio library or move through the ten bead prompts below.",
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodyLarge,
            )
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                GradientRosaryButton(
                    title = "Play full guided mystery",
                    subtitle = "Stream all 13 stages",
                    set = mystery.set,
                    onClick = { audioController.playQueue(mystery.stageTracks) },
                    modifier = Modifier.weight(1f),
                )
                Surface(
                    modifier = Modifier.weight(1f).clickable(onClick = audioController::stop),
                    shape = RoundedCornerShape(18.dp),
                    color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.08f),
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                        horizontalArrangement = Arrangement.Center,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Icon(StopIcon, contentDescription = null, tint = AppPalette.TextPrimary)
                        androidx.compose.foundation.layout.Spacer(modifier = Modifier.padding(horizontal = 4.dp))
                        Text("Stop", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
                    }
                }
            }
        }

        SectionCard {
            Text("Guided audio stages", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            mystery.stageTracks.forEachIndexed { index, track ->
                val isCurrent = audioController.isCurrent(track)
                val status = if (isCurrent) {
                    if (audioController.isPlaying) "Now playing" else "Paused"
                } else {
                    "Tap to stream this stage"
                }

                Surface(
                    modifier = Modifier.fillMaxWidth().clickable { audioController.toggle(track) },
                    shape = RoundedCornerShape(18.dp),
                    color = androidx.compose.ui.graphics.Color.White.copy(alpha = if (isCurrent) 0.12f else 0.05f),
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        horizontalArrangement = Arrangement.spacedBy(14.dp),
                    ) {
                        Text("${index + 1}", color = if (isCurrent) AppPalette.TextPrimary else AppPalette.Gold, style = MaterialTheme.typography.titleMedium)
                        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(track.subtitle, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
                            Text(status, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodySmall)
                        }
                        Icon(
                            imageVector = if (isCurrent && audioController.isPlaying) StopIcon else PlayIcon,
                            contentDescription = null,
                            tint = if (isCurrent) AppPalette.TextPrimary else AppPalette.Gold,
                        )
                    }
                }
            }
        }

        SectionCard {
            Text("Meditation beads", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            mystery.steps.chunked(2).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    row.forEachIndexed { rowIndex, step ->
                        val absoluteIndex = mystery.steps.indexOf(step) + 1
                        MeditationStepCard(
                            index = absoluteIndex,
                            step = step,
                            set = mystery.set,
                            modifier = Modifier.weight(1f),
                        )
                    }
                    if (row.size == 1) {
                        androidx.compose.foundation.layout.Spacer(modifier = Modifier.weight(1f))
                    }
                }
            }
        }

        SectionCard {
            Text("Core rosary prayers", color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
            SaintCharbelLibrary.prayers.forEach { prayer ->
                PrayerDisclosureCard(prayer)
            }
            ActionLabelRow(
                title = "Open this mystery on marsharbel.com",
                icon = symbolIcon("safari"),
                tint = AppPalette.TextPrimary,
                modifier = Modifier
                    .clip(RoundedCornerShape(18.dp))
                    .background(AppPalette.Gold.copy(alpha = 0.14f))
                    .clickable {
                        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(mystery.webUrl)))
                    }
                    .padding(horizontal = 16.dp, vertical = 14.dp),
            )
        }
    }
}

@Composable
fun PrayerReferenceScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        SectionCard {
            PillLabel("Prayer reference", icon = symbolIcon("text.book.closed"))
            Text("Core texts for personal prayer or guided rosary sessions.", color = AppPalette.TextPrimary, style = MaterialTheme.typography.displayMedium)
            Text("These texts match the prayer flow already used throughout the website.", color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyLarge)
        }

        SaintCharbelLibrary.prayers.forEach { prayer ->
            SectionCard {
                Text(prayer.title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
                Text(prayer.body, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyLarge)
                prayer.note?.let {
                    Text(it, color = AppPalette.Gold, style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}

@Composable
private fun GradientRosaryButton(
    title: String,
    subtitle: String,
    set: RosarySet,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Surface(
        modifier = modifier.clickable(onClick = onClick),
        shape = RoundedCornerShape(20.dp),
        color = androidx.compose.ui.graphics.Color.Transparent,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(AppPalette.gradient(set), RoundedCornerShape(20.dp))
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
                Text(subtitle, color = AppPalette.TextPrimary.copy(alpha = 0.88f), style = MaterialTheme.typography.bodyMedium)
            }
            Icon(symbolIcon(set.symbol), contentDescription = null, tint = AppPalette.TextPrimary)
        }
    }
}

@Composable
private fun RosarySetCard(set: RosarySet, onClick: () -> Unit) {
    SectionCard(modifier = Modifier.clickable(onClick = onClick)) {
        Row(verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                PillLabel(set.schedule, icon = symbolIcon(set.symbol))
                Text(set.title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleLarge)
                Text(set.summary, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
            }
            Icon(symbolIcon(set.symbol), contentDescription = null, tint = AppPalette.accent(set))
        }
    }
}

@Composable
private fun MeditationStepCard(
    index: Int,
    step: String,
    set: RosarySet,
    modifier: Modifier = Modifier,
) {
    Surface(
        modifier = modifier,
        shape = RoundedCornerShape(20.dp),
        color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.05f),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text("Hail Mary $index", color = AppPalette.accent(set), style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold))
            Text(step, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
private fun PrayerDisclosureCard(prayer: PrayerText) {
    var expanded by remember { mutableStateOf(false) }

    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.05f),
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { expanded = !expanded }
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            Text(prayer.title, color = AppPalette.TextPrimary, style = MaterialTheme.typography.titleMedium)
            if (expanded) {
                Text(prayer.body, color = AppPalette.TextSecondary, style = MaterialTheme.typography.bodyMedium)
                prayer.note?.let {
                    Text(it, color = AppPalette.Gold, style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}
