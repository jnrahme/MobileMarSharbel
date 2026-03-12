import SwiftUI

struct RosaryHubView: View {
    private var recommendedSet: RosarySet {
        RosarySet.recommended()
    }

    private var orderedSets: [RosarySet] {
        [recommendedSet] + RosarySet.allCases.filter { $0 != recommendedSet }
    }

    var body: some View {
        ThemedScrollView {
            SectionCard {
                PillLabel("Rosary companion", systemImage: "sparkles")

                Text("A calm guided path for daily Rosary prayer.")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Use the prayer flow, choose a mystery set, and optionally stream the guided audio already hosted on marsharbel.com.")
                    .foregroundStyle(AppTheme.textSecondary)

                NavigationLink {
                    RosarySetView(set: recommendedSet)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Start with today's set")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("\(recommendedSet.title) • \(recommendedSet.schedule)")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.accent(for: recommendedSet))
                        }

                        Spacer()

                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppTheme.gradient(for: recommendedSet).opacity(0.24))
                    )
                }
                .buttonStyle(.plain)
            }

            SectionCard {
                Text("Prayer flow")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                ForEach(Array(SaintCharbelLibrary.rosarySequence.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.gold)
                            .frame(width: 22)

                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }

            SectionCard {
                Text("Choose your pace")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                ForEach(SaintCharbelLibrary.coachPlans) { plan in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(plan.minutes) minutes • \(plan.decades) \(plan.decades == 1 ? "decade" : "decades")")
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(plan.summary)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }

            NavigationLink {
                PrayerReferenceView()
            } label: {
                SectionCard {
                    Text("Prayer reference")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Keep the Apostles' Creed, Hail Mary, Glory Be, Fatima Prayer, Hail Holy Queen, and the concluding prayer close at hand.")
                        .foregroundStyle(AppTheme.textSecondary)

                    Label("Open prayer texts", systemImage: "text.book.closed")
                        .font(.headline)
                        .foregroundStyle(AppTheme.gold)
                }
            }
            .buttonStyle(.plain)

            ForEach(orderedSets) { set in
                NavigationLink {
                    RosarySetView(set: set)
                } label: {
                    RosarySetCard(set: set)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Rosary")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct RosarySetView: View {
    let set: RosarySet

    var mysteries: [RosaryMystery] {
        SaintCharbelLibrary.mysteries(for: set)
    }

    var body: some View {
        ThemedScrollView {
            SectionCard {
                PillLabel(set.schedule, systemImage: set.symbolName)

                Text(set.title)
                    .font(.system(size: 32, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(set.summary)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(mysteries) { mystery in
                NavigationLink {
                    RosaryMysteryDetailView(mystery: mystery)
                } label: {
                    SectionCard {
                        Text("Mystery \(mystery.number)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.accent(for: set))

                        Text(mystery.title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(mystery.fruit)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)

                        Text(mystery.steps.first ?? "")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary.opacity(0.92))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(set.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RosaryMysteryDetailView: View {
    @Environment(AudioPlayerModel.self) private var audioPlayer

    let mystery: RosaryMystery

    private let meditationColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ThemedScrollView {
            headerSection
            guidedStageSection
            meditationSection
            prayerSection
        }
        .navigationTitle(mystery.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        SectionCard {
            PillLabel(mystery.day, systemImage: mystery.set.symbolName)

            Text(mystery.title)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Fruit: \(mystery.fruit)")
                .font(.headline)
                .foregroundStyle(AppTheme.accent(for: mystery.set))

            Text("Stream the guided meditation from the website's audio library or move through the ten bead prompts below.")
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: 12) {
                Button {
                    audioPlayer.playQueue(mystery.stageTracks)
                } label: {
                    Label("Play full guided mystery", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(MysteryActionButtonStyle(fill: AppTheme.gradient(for: mystery.set)))

                Button {
                    audioPlayer.stop()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(MysterySecondaryButtonStyle())
            }
        }
    }

    private var guidedStageSection: some View {
        SectionCard {
            Text("Guided audio stages")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            ForEach(Array(mystery.stageTracks.enumerated()), id: \.element.id) { index, track in
                let isCurrent = audioPlayer.isCurrent(track)
                let statusText = isCurrent ? (audioPlayer.isPlaying ? "Now playing" : "Paused") : "Tap to stream this stage"

                Button {
                    audioPlayer.toggle(track: track)
                } label: {
                    MysteryStageRow(
                        index: index + 1,
                        track: track,
                        isCurrent: isCurrent,
                        isPlaying: audioPlayer.isPlaying,
                        statusText: statusText,
                        set: mystery.set
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var meditationSection: some View {
        SectionCard {
            Text("Meditation beads")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            LazyVGrid(columns: meditationColumns, spacing: 12) {
                ForEach(Array(mystery.steps.enumerated()), id: \.offset) { index, step in
                    MeditationStepCard(index: index + 1, step: step, set: mystery.set)
                }
            }
        }
    }

    private var prayerSection: some View {
        SectionCard {
            Text("Core rosary prayers")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            ForEach(SaintCharbelLibrary.prayers) { prayer in
                PrayerDisclosureCard(prayer: prayer)
            }

            if let url = mystery.webURL {
                Link(destination: url) {
                    Label("Open this mystery on marsharbel.com", systemImage: "safari")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(AppTheme.gold.opacity(0.14))
                        )
                }
            }
        }
    }
}

struct PrayerReferenceView: View {
    var body: some View {
        ThemedScrollView {
            SectionCard {
                PillLabel("Prayer reference", systemImage: "text.book.closed")

                Text("Core texts for personal prayer or guided rosary sessions.")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("These texts match the prayer flow already used throughout the website.")
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(SaintCharbelLibrary.prayers) { prayer in
                SectionCard {
                    Text(prayer.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(prayer.body)
                        .font(.body)
                        .foregroundStyle(AppTheme.textSecondary)

                    if let note = prayer.note {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(AppTheme.gold)
                    }
                }
            }
        }
        .navigationTitle("Prayers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct RosarySetCard: View {
    let set: RosarySet

    var body: some View {
        SectionCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    PillLabel(set.schedule, systemImage: set.symbolName)

                    Text(set.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(set.summary)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer(minLength: 16)

                Image(systemName: set.symbolName)
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.accent(for: set))
            }
        }
    }
}

private struct MysteryStageRow: View {
    let index: Int
    let track: AudioTrack
    let isCurrent: Bool
    let isPlaying: Bool
    let statusText: String
    let set: RosarySet

    private var backgroundColor: Color {
        isCurrent ? Color.white.opacity(0.12) : Color.white.opacity(0.05)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(index)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isCurrent ? AppTheme.textPrimary : AppTheme.gold)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(track.subtitle)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: isCurrent && isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.title3)
                .foregroundStyle(isCurrent ? AppTheme.textPrimary : AppTheme.gold)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isCurrent ? AppTheme.accent(for: set).opacity(0.45) : .clear, lineWidth: 1)
                )
        )
    }
}

private struct MeditationStepCard: View {
    let index: Int
    let step: String
    let set: RosarySet

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hail Mary \(index)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.accent(for: set))

            Text(step)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

private struct PrayerDisclosureCard: View {
    let prayer: PrayerText

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 8) {
                Text(prayer.body)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)

                if let note = prayer.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        } label: {
            Text(prayer.title)
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .tint(AppTheme.gold)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

private struct MysteryActionButtonStyle: ButtonStyle {
    let fill: LinearGradient

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(fill.opacity(configuration.isPressed ? 0.78 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct MysterySecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.12 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
