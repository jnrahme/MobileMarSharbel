import AVFoundation
import Foundation
import Observation

struct AudioTrack: Hashable, Identifiable {
    let url: URL
    let title: String
    let subtitle: String

    var id: String {
        url.absoluteString
    }
}

@Observable
final class AudioPlayerModel {
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var endObserver: NSObjectProtocol?
    private var queuedTracks: [AudioTrack] = []
    private var queuedIndex = 0

    private(set) var currentTrack: AudioTrack?
    private(set) var isPlaying = false
    private(set) var progress: Double = 0
    private(set) var duration: Double = 0

    var hasActiveTrack: Bool {
        currentTrack != nil
    }

    init() {
        configureAudioSession()
    }

    func toggle(track: AudioTrack) {
        if isCurrent(track) {
            togglePlayPause()
            return
        }

        play(track: track)
    }

    func play(track: AudioTrack) {
        queuedTracks = []
        queuedIndex = 0
        start(track: track)
    }

    func playQueue(_ tracks: [AudioTrack]) {
        guard let firstTrack = tracks.first else { return }
        queuedTracks = tracks
        queuedIndex = 0
        start(track: firstTrack)
    }

    func togglePlayPause() {
        guard let player else { return }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func stop() {
        clearPlayer()
        currentTrack = nil
        progress = 0
        duration = 0
        queuedTracks = []
        queuedIndex = 0
    }

    func isCurrent(_ track: AudioTrack) -> Bool {
        currentTrack?.id == track.id
    }

    private func start(track: AudioTrack) {
        clearPlayer()

        let item = AVPlayerItem(url: track.url)
        let player = AVPlayer(playerItem: item)

        self.player = player
        currentTrack = track
        progress = 0
        duration = 0

        installObservers(for: item, player: player)

        player.play()
        isPlaying = true
    }

    private func installObservers(for item: AVPlayerItem, player: AVPlayer) {
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self else { return }

            self.progress = max(time.seconds, 0)

            let currentDuration = player.currentItem?.duration.seconds ?? 0
            if currentDuration.isFinite, currentDuration > 0 {
                self.duration = currentDuration
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.advanceQueueOrStop()
        }
    }

    private func advanceQueueOrStop() {
        guard !queuedTracks.isEmpty else {
            stop()
            return
        }

        let nextIndex = queuedIndex + 1
        guard nextIndex < queuedTracks.count else {
            stop()
            return
        }

        queuedIndex = nextIndex
        start(track: queuedTracks[nextIndex])
    }

    private func clearPlayer() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }

        if let timeObserverToken, let player {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }

        player?.pause()
        player = nil
        isPlaying = false
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.allowAirPlay, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error.localizedDescription)")
        }
    }
}
