package com.jnrahme.androidsaintcharbel.core.model

import java.time.DayOfWeek
import java.time.LocalDate

data class AudioTrack(
    val url: String,
    val title: String,
    val subtitle: String,
) {
    val id: String = url
}

data class SaintStoryBook(
    val id: String,
    val saintName: String,
    val title: String,
    val subtitle: String,
    val description: String,
    val ageBand: String,
    val coverPrompt: String,
    val pages: List<StoryBookPage>,
) {
    val narratedPageCount: Int
        get() = pages.count { it.audioTrack != null }
}

data class StoryBookPage(
    val number: Int,
    val title: String,
    val body: String,
    val prayer: String,
    val heart: String,
    val imageUrl: String,
    val audioTrack: AudioTrack?,
) {
    val pageLabel: String
        get() = "Page $number"

    val isNarrated: Boolean
        get() = audioTrack != null
}

data class PrayerText(
    val title: String,
    val body: String,
    val note: String? = null,
)

data class CoachPlan(
    val minutes: Int,
    val decades: Int,
    val summary: String,
)

enum class RosarySet(
    val title: String,
    val schedule: String,
    val summary: String,
    val symbol: String,
) {
    JOYFUL(
        title = "Joyful Mysteries",
        schedule = "Monday / Saturday",
        summary = "Pray with the hidden life of Jesus and Mary's generous yes.",
        symbol = "sun.max.fill",
    ),
    LUMINOUS(
        title = "Luminous Mysteries",
        schedule = "Thursday",
        summary = "Walk with Christ in His public ministry and let His light reform the heart.",
        symbol = "sparkles",
    ),
    SORROWFUL(
        title = "Sorrowful Mysteries",
        schedule = "Tuesday / Friday",
        summary = "Stay near Jesus in surrender, suffering, and redeeming love.",
        symbol = "drop.fill",
    ),
    GLORIOUS(
        title = "Glorious Mysteries",
        schedule = "Wednesday / Sunday",
        summary = "Pray from resurrection hope toward mission, heaven, and perseverance.",
        symbol = "crown.fill",
    );

    companion object {
        fun recommended(on: LocalDate = LocalDate.now()): RosarySet = when (on.dayOfWeek) {
            DayOfWeek.MONDAY,
            DayOfWeek.SATURDAY,
            -> JOYFUL
            DayOfWeek.TUESDAY,
            DayOfWeek.FRIDAY,
            -> SORROWFUL
            DayOfWeek.THURSDAY -> LUMINOUS
            else -> GLORIOUS
        }
    }
}

data class RosaryMystery(
    val key: String,
    val set: RosarySet,
    val number: Int,
    val title: String,
    val day: String,
    val fruit: String,
    val steps: List<String>,
) {
    val webUrl: String
        get() = "https://marsharbel.com/mysteries/${set.name.lowercase()}-$number.html"

    val stageTracks: List<AudioTrack>
        get() = (1..13).map { stage ->
            AudioTrack(
                url = "https://marsharbel.com/media/rosary/$key/step-${stage.toString().padStart(2, '0')}.mp3",
                title = title,
                subtitle = stageSubtitle(stage),
            )
        }

    private fun stageSubtitle(stage: Int): String = when (stage) {
        1 -> "Receive the mystery"
        2 -> "Listen to the Word"
        in 3..12 -> steps[stage - 3]
        13 -> "Glory Be and Fatima Prayer"
        else -> "Guided prayer"
    }
}

