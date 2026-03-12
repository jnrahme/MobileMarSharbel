package com.jnrahme.androidsaintcharbel.core.health

import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.jnrahme.androidsaintcharbel.core.model.RosarySet
import com.jnrahme.androidsaintcharbel.core.model.SaintCharbelLibrary
import com.jnrahme.androidsaintcharbel.core.model.StoryCatalog
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.net.HttpURLConnection
import java.net.URL
import java.time.Instant

enum class AppHealthState {
    CHECKING,
    HEALTHY,
    DEGRADED,
    UNAVAILABLE,
}

data class AppHealthService(
    val title: String,
    val detail: String,
    val url: String,
)

data class AppHealthCheckResult(
    val service: AppHealthService,
    val state: AppHealthState,
    val summary: String,
)

private val services = listOf(
    AppHealthService("Website", "Main Saint Charbel website shell", "https://marsharbel.com"),
    AppHealthService("Story page", "Live story landing page", "https://marsharbel.com/story.html"),
    AppHealthService("Story artwork", "Website storybook illustration stream", StoryCatalog.saintCharbel.pages.first().imageUrl),
    AppHealthService("Story narration", "Website narration audio stream", StoryCatalog.saintCharbel.pages.first().audioTrack!!.url),
    AppHealthService("Rosary audio", "Guided rosary audio stream", SaintCharbelLibrary.mysteries(RosarySet.JOYFUL).first().stageTracks.first().url),
)

@Stable
class AppHealthModel {
    val results = mutableStateListOf<AppHealthCheckResult>()
    var isRefreshing by mutableStateOf(false)
        private set
    var lastChecked by mutableStateOf<Instant?>(null)
        private set
    var overallState by mutableStateOf(AppHealthState.CHECKING)
        private set

    suspend fun refreshIfNeeded() {
        if (results.isEmpty()) {
            refresh()
        }
    }

    suspend fun refresh() {
        isRefreshing = true
        overallState = AppHealthState.CHECKING

        val fresh = withContext(Dispatchers.IO) {
            services.map(::checkService)
        }

        results.clear()
        results.addAll(fresh)
        overallState = when {
            fresh.any { it.state == AppHealthState.UNAVAILABLE } -> AppHealthState.UNAVAILABLE
            fresh.any { it.state == AppHealthState.DEGRADED } -> AppHealthState.DEGRADED
            else -> AppHealthState.HEALTHY
        }
        lastChecked = Instant.now()
        isRefreshing = false
    }

    private fun checkService(service: AppHealthService): AppHealthCheckResult {
        val start = System.nanoTime()
        return runCatching {
            val first = request(service.url, "HEAD")
            val status = if (first in 200..399) first else request(service.url, "GET", range = true)
            val elapsedMs = (System.nanoTime() - start) / 1_000_000
            when {
                status !in 200..399 -> AppHealthCheckResult(service, AppHealthState.UNAVAILABLE, "Unavailable ($status)")
                elapsedMs > 1500 -> AppHealthCheckResult(service, AppHealthState.DEGRADED, "Slow response (${elapsedMs}ms)")
                else -> AppHealthCheckResult(service, AppHealthState.HEALTHY, "Healthy (${elapsedMs}ms)")
            }
        }.getOrElse { error ->
            AppHealthCheckResult(service, AppHealthState.UNAVAILABLE, error.message ?: "Check failed")
        }
    }

    private fun request(url: String, method: String, range: Boolean = false): Int {
        val connection = (URL(url).openConnection() as HttpURLConnection).apply {
            requestMethod = method
            connectTimeout = 4000
            readTimeout = 4000
            instanceFollowRedirects = true
            if (range) {
                setRequestProperty("Range", "bytes=0-0")
            }
        }

        return try {
            connection.connect()
            connection.responseCode
        } finally {
            connection.disconnect()
        }
    }
}
