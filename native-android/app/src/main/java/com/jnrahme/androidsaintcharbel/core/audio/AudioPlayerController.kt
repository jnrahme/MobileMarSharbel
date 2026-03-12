package com.jnrahme.androidsaintcharbel.core.audio

import android.content.Context
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import com.jnrahme.androidsaintcharbel.core.model.AudioTrack
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Stable
class AudioPlayerController(context: Context) {
    private val player = ExoPlayer.Builder(context).build()
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var queue: List<AudioTrack> = emptyList()

    var currentTrack by mutableStateOf<AudioTrack?>(null)
        private set
    var isPlaying by mutableStateOf(false)
        private set
    var progress by mutableDoubleStateOf(0.0)
        private set
    var duration by mutableDoubleStateOf(0.0)
        private set

    val hasActiveTrack: Boolean
        get() = currentTrack != null

    init {
        player.addListener(object : Player.Listener {
            override fun onIsPlayingChanged(playing: Boolean) {
                isPlaying = playing
            }

            override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
                currentTrack = queue.getOrNull(player.currentMediaItemIndex)
            }

            override fun onPlaybackStateChanged(playbackState: Int) {
                if (playbackState == Player.STATE_ENDED && player.currentMediaItemIndex >= queue.lastIndex) {
                    stop()
                }
            }
        })

        scope.launch {
            while (true) {
                progress = if (currentTrack != null) player.currentPosition.coerceAtLeast(0L) / 1000.0 else 0.0
                duration = if (currentTrack != null && player.duration > 0L) player.duration / 1000.0 else 0.0
                delay(250)
            }
        }
    }

    fun toggle(track: AudioTrack) {
        if (isCurrent(track)) {
            togglePlayPause()
        } else {
            play(track)
        }
    }

    fun play(track: AudioTrack) {
        playQueue(listOf(track))
    }

    fun playQueue(tracks: List<AudioTrack>) {
        if (tracks.isEmpty()) return
        queue = tracks
        currentTrack = tracks.first()
        player.setMediaItems(tracks.map { MediaItem.fromUri(it.url) }, 0, 0L)
        player.prepare()
        player.playWhenReady = true
        player.play()
    }

    fun togglePlayPause() {
        if (player.isPlaying) {
            player.pause()
        } else {
            player.play()
        }
        isPlaying = player.isPlaying
    }

    fun stop() {
        player.stop()
        player.clearMediaItems()
        queue = emptyList()
        currentTrack = null
        isPlaying = false
        progress = 0.0
        duration = 0.0
    }

    fun isCurrent(track: AudioTrack): Boolean = currentTrack?.id == track.id

    fun release() {
        scope.cancel()
        player.release()
    }
}

@Composable
fun rememberAudioPlayerController(): AudioPlayerController {
    val context = LocalContext.current.applicationContext
    return remember(context) { AudioPlayerController(context) }
}

