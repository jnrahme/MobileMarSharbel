package com.jnrahme.androidsaintcharbel.core.ui

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.automirrored.rounded.ArrowForward
import androidx.compose.material.icons.automirrored.rounded.TextSnippet
import androidx.compose.material.icons.rounded.AutoStories
import androidx.compose.material.icons.rounded.Book
import androidx.compose.material.icons.rounded.CatchingPokemon
import androidx.compose.material.icons.rounded.ChangeHistory
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.Close
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material.icons.rounded.Language
import androidx.compose.material.icons.rounded.Pause
import androidx.compose.material.icons.rounded.PlayArrow
import androidx.compose.material.icons.rounded.Refresh
import androidx.compose.material.icons.rounded.Spa
import androidx.compose.material.icons.rounded.Star
import androidx.compose.material.icons.rounded.Warning
import androidx.compose.material.icons.rounded.WaterDrop
import androidx.compose.material.icons.rounded.WorkspacePremium
import androidx.compose.ui.graphics.vector.ImageVector

fun symbolIcon(symbol: String): ImageVector = when (symbol) {
    "house.fill" -> Icons.Rounded.Home
    "book.closed.fill", "book.pages.fill", "books.vertical.fill" -> Icons.Rounded.AutoStories
    "sparkles" -> Icons.Rounded.Star
    "sun.max.fill" -> Icons.Rounded.Spa
    "drop.fill" -> Icons.Rounded.WaterDrop
    "crown.fill" -> Icons.Rounded.WorkspacePremium
    "text.book.closed" -> Icons.AutoMirrored.Rounded.TextSnippet
    "safari", "dot.radiowaves.left.and.right" -> Icons.Rounded.Language
    else -> Icons.Rounded.CatchingPokemon
}

val BackIcon: ImageVector = Icons.AutoMirrored.Rounded.ArrowBack
val ForwardIcon: ImageVector = Icons.AutoMirrored.Rounded.ArrowForward
val PlayIcon: ImageVector = Icons.Rounded.PlayArrow
val PauseIcon: ImageVector = Icons.Rounded.Pause
val StopIcon: ImageVector = Icons.Rounded.Close
val RefreshIcon: ImageVector = Icons.Rounded.Refresh
val CheckIcon: ImageVector = Icons.Rounded.CheckCircle
val WarningIcon: ImageVector = Icons.Rounded.Warning
val StoryOpenIcon: ImageVector = Icons.Rounded.Book
val TriangleIcon: ImageVector = Icons.Rounded.ChangeHistory
