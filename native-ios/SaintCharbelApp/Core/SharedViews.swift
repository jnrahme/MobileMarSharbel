import SwiftUI

struct ThemedScrollView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.gold.opacity(0.15))
                .frame(width: 320, height: 320)
                .blur(radius: 18)
                .offset(x: -140, y: -280)

            Circle()
                .fill(AppTheme.rose.opacity(0.16))
                .frame(width: 260, height: 260)
                .blur(radius: 20)
                .offset(x: 150, y: 260)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct SectionCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.panel.opacity(0.94))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(AppTheme.panelBorder, lineWidth: 1)
                )
        )
    }
}

struct PillLabel: View {
    let text: String
    let systemImage: String?

    init(_ text: String, systemImage: String? = nil) {
        self.text = text
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
            }

            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(AppTheme.gold)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(AppTheme.gold.opacity(0.12))
        )
    }
}

struct StatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.textPrimary)

            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct MiniPlayerView: View {
    @Environment(AudioPlayerModel.self) private var audioPlayer

    var body: some View {
        if let track = audioPlayer.currentTrack {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.18))
                        .frame(width: 42, height: 42)

                    Image(systemName: "waveform")
                        .foregroundStyle(AppTheme.gold)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(track.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    Text(track.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)

                    ProgressView(value: audioPlayer.progress, total: max(audioPlayer.duration, 1))
                        .tint(AppTheme.gold)
                }

                Spacer(minLength: 10)

                Button {
                    audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    audioPlayer.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 16, y: 10)
        }
    }
}
