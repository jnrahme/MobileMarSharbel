import SwiftUI

struct StoryLibraryView: View {
    private let stories = StoryCatalog.all

    var body: some View {
        ThemedScrollView {
            SectionCard {
                PillLabel("Storybook shelf", systemImage: "books.vertical.fill")

                Text("Choose a saint story and read it like a real book.")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("The library is designed around reusable story manifests, so Saint Charbel can be the first of many child-friendly saints without rebuilding the reader later.")
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(stories) { story in
                NavigationLink {
                    StoryBookReaderView(story: story)
                } label: {
                    StoryBookShelfCard(story: story)
                }
                .buttonStyle(.plain)
            }

            SectionCard {
                Text("Built for young readers")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                StoryPrincipleRow(title: "Simple first-use flow", detail: "One story card opens one swipe reader, so children never have to decode a complex menu.")
                StoryPrincipleRow(title: "Listening built in", detail: "Narration starts from the current page and can keep moving through the book without extra setup.")
                StoryPrincipleRow(title: "Ready for more saints", detail: "Each future story only needs a new page manifest, artwork, and audio source.")
            }
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct StoryBookShelfCard: View {
    let story: SaintStoryBook

    var body: some View {
        SectionCard {
            ZStack(alignment: .bottomLeading) {
                StoryRemoteImage(url: story.pages.first?.imageURL)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.1), Color.black.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    )

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        StoryTag(text: story.ageBand, fill: AppTheme.gold.opacity(0.22), foreground: AppTheme.textPrimary)
                        StoryTag(text: "\(story.pages.count) pages", fill: Color.white.opacity(0.14), foreground: AppTheme.textPrimary)
                        StoryTag(text: "\(story.narratedPageCount) narrated", fill: AppTheme.storyBlue.opacity(0.34), foreground: AppTheme.textPrimary)
                    }

                    Text(story.title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(Color.white)

                    Text(story.coverPrompt)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
                .padding(18)
            }

            Text(story.description)
                .foregroundStyle(AppTheme.textSecondary)

            HStack {
                Label("Open storybook", systemImage: "book.pages.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold)
            }
        }
    }
}

struct StoryBookReaderView: View {
    @Environment(AudioPlayerModel.self) private var audioPlayer

    let story: SaintStoryBook

    @State private var selectedPageIndex = 0
    @State private var followNarration = false

    private var currentPage: StoryBookPage {
        story.pages[selectedPageIndex]
    }

    private var currentTrackID: String? {
        audioPlayer.currentTrack?.id
    }

    private var progressValue: Double {
        Double(selectedPageIndex + 1)
    }

    private var currentAudioTrack: AudioTrack? {
        currentPage.audioTrack
    }

    private var narrationButtonTitle: String {
        guard currentPage.isNarrated else {
            return "Narration complete"
        }

        guard let currentAudioTrack else {
            return "Read to Me"
        }

        if audioPlayer.isCurrent(currentAudioTrack) {
            return audioPlayer.isPlaying ? "Pause" : "Keep Listening"
        }

        return "Read to Me"
    }

    private var narrationButtonIcon: String {
        guard currentPage.isNarrated else {
            return "checkmark.circle"
        }

        guard let currentAudioTrack else {
            return "speaker.wave.2.fill"
        }

        if audioPlayer.isCurrent(currentAudioTrack) {
            return audioPlayer.isPlaying ? "pause.fill" : "play.fill"
        }

        return "speaker.wave.2.fill"
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppTheme.storybookGradient
                    .ignoresSafeArea()

                Circle()
                    .fill(AppTheme.storyBlue.opacity(0.26))
                    .frame(width: 260, height: 260)
                    .blur(radius: 18)
                    .offset(x: -120, y: -280)

                Circle()
                    .fill(AppTheme.storyBerry.opacity(0.18))
                    .frame(width: 240, height: 240)
                    .blur(radius: 18)
                    .offset(x: 140, y: 260)

                VStack(spacing: 18) {
                    StoryReaderHeader(
                        saintName: story.saintName,
                        title: story.title,
                        currentPage: selectedPageIndex + 1,
                        totalPages: story.pages.count,
                        progressValue: progressValue
                    )

                    TabView(selection: $selectedPageIndex) {
                        ForEach(Array(story.pages.enumerated()), id: \.element.id) { index, page in
                            StoryBookPageCard(page: page)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: min(proxy.size.height * 0.68, 660))

                    StoryReaderControls(
                        currentPage: currentPage,
                        title: narrationButtonTitle,
                        systemImage: narrationButtonIcon,
                        canGoBack: selectedPageIndex > 0,
                        canGoForward: selectedPageIndex < story.pages.count - 1,
                        isNarratingCurrentPage: currentAudioTrack.map(audioPlayer.isCurrent) ?? false,
                        onBack: stepBackward,
                        onNarrate: toggleNarration,
                        onForward: stepForward,
                        onStop: stopNarration
                    )
                }
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(story.saintName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: currentTrackID) { _, newValue in
            guard followNarration else { return }

            guard let newValue else {
                followNarration = false
                return
            }

            guard let pageIndex = story.pages.firstIndex(where: { $0.audioTrack?.id == newValue }) else {
                return
            }

            withAnimation(.easeInOut(duration: 0.35)) {
                selectedPageIndex = pageIndex
            }
        }
    }

    private func stepBackward() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            selectedPageIndex = max(selectedPageIndex - 1, 0)
        }
    }

    private func stepForward() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            selectedPageIndex = min(selectedPageIndex + 1, story.pages.count - 1)
        }
    }

    private func toggleNarration() {
        guard let track = currentAudioTrack else { return }

        if audioPlayer.isCurrent(track) {
            audioPlayer.togglePlayPause()
            return
        }

        followNarration = true
        let queue = Array(story.pages[selectedPageIndex...].compactMap(\.audioTrack))
        audioPlayer.playQueue(queue)
    }

    private func stopNarration() {
        followNarration = false
        audioPlayer.stop()
    }
}

private struct StoryReaderHeader: View {
    let saintName: String
    let title: String
    let currentPage: Int
    let totalPages: Int
    let progressValue: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                PillLabel(saintName, systemImage: "sparkles")
                Spacer()
                StoryTag(text: "Page \(currentPage) of \(totalPages)", fill: Color.white.opacity(0.12), foreground: AppTheme.textPrimary)
            }

            Text(title)
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.textPrimary)

            ProgressView(value: progressValue, total: Double(totalPages))
                .tint(AppTheme.gold)
        }
        .padding(.horizontal, 20)
    }
}

private struct StoryBookPageCard: View {
    let page: StoryBookPage

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.paper, AppTheme.paperShadow.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.24), radius: 22, y: 12)

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        StoryTag(
                            text: page.isNarrated ? "\(page.pageLabel)  •  audio" : page.pageLabel,
                            fill: Color.black.opacity(0.12),
                            foreground: AppTheme.ink
                        )

                        Spacer()

                        StoryTag(
                            text: page.isNarrated ? "Narration ready" : "Image only",
                            fill: page.isNarrated ? AppTheme.gold.opacity(0.14) : Color.black.opacity(0.08),
                            foreground: page.isNarrated ? AppTheme.ink : AppTheme.ink.opacity(0.7)
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text(page.title)
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundStyle(AppTheme.ink)

                        Text(page.body)
                            .font(.body)
                            .foregroundStyle(AppTheme.ink.opacity(0.84))
                    }

                    StoryRemoteImage(url: page.imageURL)
                        .aspectRatio(3.0 / 2.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.black.opacity(0.05))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.white.opacity(0.65), lineWidth: 1)
                        )

                    StoryPageReflectionCard(
                        title: "Little prayer",
                        message: page.prayer,
                        tint: AppTheme.gold.opacity(0.18),
                        foreground: AppTheme.ink
                    )

                    StoryPageReflectionCard(
                        title: "Heart moment",
                        message: page.heart,
                        tint: Color.white.opacity(0.55),
                        foreground: AppTheme.ink
                    )

                    Text("Swipe sideways to turn pages. Scroll this page to keep reading while the artwork stays part of the story.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(page.pageLabel). \(page.title).")
    }
}

private struct StoryReaderControls: View {
    let currentPage: StoryBookPage
    let title: String
    let systemImage: String
    let canGoBack: Bool
    let canGoForward: Bool
    let isNarratingCurrentPage: Bool
    let onBack: () -> Void
    let onNarrate: () -> Void
    let onForward: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                StoryRoundButton(systemImage: "arrow.left", disabled: !canGoBack, action: onBack)

                Button(action: onNarrate) {
                    Label(title, systemImage: systemImage)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(currentPage.isNarrated ? AppTheme.ink : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(currentPage.isNarrated ? AppTheme.paper : Color.white.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
                .disabled(!currentPage.isNarrated)

                StoryRoundButton(systemImage: "arrow.right", disabled: !canGoForward, action: onForward)
            }

            if isNarratingCurrentPage {
                Button(action: onStop) {
                    Label("Stop narration", systemImage: "xmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.9))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct StoryPageReflectionCard: View {
    let title: String
    let message: String
    let tint: Color
    let foreground: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(foreground)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(foreground.opacity(0.86))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(tint)
        )
    }
}

private struct StoryRemoteImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.18))

                    ProgressView()
                        .tint(AppTheme.gold)
                }
            case let .success(image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.12))

                    VStack(spacing: 10) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(AppTheme.gold)

                        Text("Artwork unavailable")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

private struct StoryRoundButton: View {
    let systemImage: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .foregroundStyle(disabled ? AppTheme.textSecondary.opacity(0.55) : AppTheme.textPrimary)
                .frame(width: 54, height: 54)
                .background(
                    Circle()
                        .fill(Color.white.opacity(disabled ? 0.06 : 0.12))
                )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}

private struct StoryTag: View {
    let text: String
    let fill: Color
    let foreground: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(fill)
            )
    }
}

private struct StoryPrincipleRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}
