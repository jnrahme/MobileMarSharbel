package com.jnrahme.androidsaintcharbel.core.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.jnrahme.androidsaintcharbel.core.audio.AudioPlayerController
import com.jnrahme.androidsaintcharbel.core.theme.AppPalette

@Composable
fun AppBackground(modifier: Modifier = Modifier, content: @Composable BoxScope.() -> Unit) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppPalette.BackgroundBrush),
    ) {
        Box(
            modifier = Modifier
                .size(320.dp)
                .blur(24.dp)
                .background(AppPalette.Gold.copy(alpha = 0.15f), CircleShape)
                .align(Alignment.TopStart)
                .padding(0.dp),
        )
        Box(
            modifier = Modifier
                .size(260.dp)
                .blur(28.dp)
                .background(AppPalette.Rose.copy(alpha = 0.14f), CircleShape)
                .align(Alignment.BottomEnd),
        )
        content()
    }
}

@Composable
fun SectionCard(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = AppPalette.Panel.copy(alpha = 0.94f),
        contentColor = AppPalette.TextPrimary,
        shape = RoundedCornerShape(28.dp),
        tonalElevation = 0.dp,
        shadowElevation = 0.dp,
    ) {
        Column(
            modifier = Modifier
                .border(1.dp, AppPalette.PanelBorder, RoundedCornerShape(28.dp))
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            content = content,
        )
    }
}

@Composable
fun PillLabel(text: String, modifier: Modifier = Modifier, icon: ImageVector? = null) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(999.dp))
            .background(AppPalette.Gold.copy(alpha = 0.12f))
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        if (icon != null) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = AppPalette.Gold,
                modifier = Modifier.size(14.dp),
            )
        }
        Text(
            text = text,
            color = AppPalette.Gold,
            style = MaterialTheme.typography.labelLarge,
        )
    }
}

@Composable
fun StoryTag(
    text: String,
    fill: Color,
    foreground: Color,
    modifier: Modifier = Modifier,
) {
    Text(
        text = text,
        modifier = modifier
            .clip(RoundedCornerShape(999.dp))
            .background(fill)
            .padding(horizontal = 11.dp, vertical = 7.dp),
        color = foreground,
        style = MaterialTheme.typography.labelLarge,
    )
}

@Composable
fun StatTile(title: String, value: String, modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = Color.White.copy(alpha = 0.05f),
        shape = RoundedCornerShape(20.dp),
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp),
        ) {
            Text(
                text = value,
                color = AppPalette.TextPrimary,
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = title,
                color = AppPalette.TextSecondary,
                style = MaterialTheme.typography.bodySmall,
            )
        }
    }
}

@Composable
fun MiniPlayerBar(
    controller: AudioPlayerController,
    modifier: Modifier = Modifier,
) {
    val track = controller.currentTrack ?: return

    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(26.dp),
        color = AppPalette.ChromeBackground.copy(alpha = 0.92f),
        tonalElevation = 0.dp,
        shadowElevation = 12.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .border(1.dp, AppPalette.ChromeBorder, RoundedCornerShape(26.dp))
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            Box(
                modifier = Modifier
                    .size(42.dp)
                    .clip(CircleShape)
                    .background(AppPalette.Gold.copy(alpha = 0.18f)),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    imageVector = symbolIcon("sparkles"),
                    contentDescription = null,
                    tint = AppPalette.Gold,
                    modifier = Modifier.size(20.dp),
                )
            }

            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = track.title,
                    color = AppPalette.TextPrimary,
                    style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.SemiBold),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Text(
                    text = track.subtitle,
                    color = AppPalette.TextSecondary,
                    style = MaterialTheme.typography.bodySmall,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                LinearProgressIndicator(
                    progress = { if (controller.duration > 0.0) (controller.progress / controller.duration).toFloat() else 0f },
                    modifier = Modifier.fillMaxWidth(),
                    color = AppPalette.Gold,
                    trackColor = Color.White.copy(alpha = 0.12f),
                )
            }

            MiniPlayerAction(
                icon = if (controller.isPlaying) PauseIcon else PlayIcon,
                tint = AppPalette.TextPrimary,
                background = Color.White.copy(alpha = 0.08f),
                onClick = controller::togglePlayPause,
            )
            MiniPlayerAction(
                icon = StopIcon,
                tint = AppPalette.TextSecondary,
                background = Color.Transparent,
                onClick = controller::stop,
            )
        }
    }
}

@Composable
private fun MiniPlayerAction(
    icon: ImageVector,
    tint: Color,
    background: Color,
    onClick: () -> Unit,
) {
    Box(
        modifier = Modifier
            .size(38.dp)
            .clip(CircleShape)
            .background(background)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = tint)
    }
}

@Composable
fun ActionLabelRow(
    title: String,
    icon: ImageVector,
    tint: Color,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(20.dp))
        Text(
            text = title,
            color = tint,
            style = MaterialTheme.typography.titleMedium,
        )
    }
}

@Composable
fun GradientPanel(
    brush: Brush,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit,
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(28.dp),
        color = Color.Transparent,
    ) {
        Column(
            modifier = Modifier
                .background(brush, RoundedCornerShape(28.dp))
                .border(1.dp, AppPalette.PanelBorder, RoundedCornerShape(28.dp))
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            content = content,
        )
    }
}

@Composable
fun HorizontalSpacer(width: Int) {
    Spacer(modifier = Modifier.width(width.dp))
}

@Composable
fun VerticalSpacer(height: Int) {
    Spacer(modifier = Modifier.height(height.dp))
}
