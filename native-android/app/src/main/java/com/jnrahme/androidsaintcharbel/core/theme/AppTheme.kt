package com.jnrahme.androidsaintcharbel.core.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.jnrahme.androidsaintcharbel.core.model.RosarySet

object AppPalette {
    val BackgroundTop = Color(0xFF121A24)
    val BackgroundBottom = Color(0xFF08101A)
    val Panel = Color(0xFF1A2431)
    val ChromeBackground = Color(0xFF0F141E)
    val ChromeBorder = Color(0x1AFFFFFF)
    val PanelBorder = Color(0x1FFFFFFF)
    val TextPrimary = Color(0xFFF5F0E3)
    val TextSecondary = Color(0xFFC8CDD1)
    val TabInactive = Color(0xFFB8BCC6)
    val Gold = Color(0xFFD8B96E)
    val Ember = Color(0xFFB67852)
    val Olive = Color(0xFF7A9466)
    val Rose = Color(0xFFA36474)
    val Paper = Color(0xFFF1E8D5)
    val PaperShadow = Color(0xFFD5BE95)
    val Ink = Color(0xFF2D2D33)
    val StoryBlue = Color(0xFF5376AA)
    val StoryBerry = Color(0xFFA55264)

    val BackgroundBrush: Brush = Brush.linearGradient(
        colors = listOf(BackgroundTop, BackgroundBottom),
    )

    val StorybookBrush: Brush = Brush.linearGradient(
        colors = listOf(
            Color(0xFF172136),
            Color(0xFF2F394F),
            Color(0xFF473526),
        ),
    )

    fun accent(set: RosarySet): Color = when (set) {
        RosarySet.JOYFUL -> Gold
        RosarySet.LUMINOUS -> Color(0xFF8FC2C8)
        RosarySet.SORROWFUL -> Rose
        RosarySet.GLORIOUS -> Olive
    }

    fun gradient(set: RosarySet): Brush = Brush.linearGradient(
        colors = when (set) {
            RosarySet.JOYFUL -> listOf(Gold.copy(alpha = 0.7f), Ember.copy(alpha = 0.65f))
            RosarySet.LUMINOUS -> listOf(Color(0xFF8AC4CC), Color(0xFF5E7BB9))
            RosarySet.SORROWFUL -> listOf(Rose.copy(alpha = 0.82f), Color(0xFF4D2D3A))
            RosarySet.GLORIOUS -> listOf(Olive.copy(alpha = 0.92f), Color(0xFF4A6A53))
        },
    )
}

private val SaintCharbelColorScheme = darkColorScheme(
    primary = AppPalette.Gold,
    secondary = AppPalette.TextSecondary,
    background = AppPalette.BackgroundBottom,
    surface = AppPalette.Panel,
    onPrimary = AppPalette.Ink,
    onSecondary = AppPalette.TextPrimary,
    onBackground = AppPalette.TextPrimary,
    onSurface = AppPalette.TextPrimary,
)

private val SaintCharbelTypography = androidx.compose.material3.Typography(
    displayLarge = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 40.sp, lineHeight = 44.sp),
    displayMedium = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 34.sp, lineHeight = 38.sp),
    headlineLarge = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 32.sp, lineHeight = 36.sp),
    headlineMedium = TextStyle(fontFamily = FontFamily.Serif, fontWeight = FontWeight.SemiBold, fontSize = 28.sp, lineHeight = 32.sp),
    titleLarge = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 22.sp, lineHeight = 28.sp),
    titleMedium = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 18.sp, lineHeight = 24.sp),
    bodyLarge = TextStyle(fontSize = 16.sp, lineHeight = 24.sp),
    bodyMedium = TextStyle(fontSize = 15.sp, lineHeight = 22.sp),
    labelLarge = TextStyle(fontWeight = FontWeight.SemiBold, fontSize = 14.sp, lineHeight = 20.sp),
)

@Composable
fun SaintCharbelTheme(content: @Composable () -> Unit) {
    val dark = isSystemInDarkTheme()
    MaterialTheme(
        colorScheme = SaintCharbelColorScheme,
        typography = SaintCharbelTypography,
        content = content,
    )
}

