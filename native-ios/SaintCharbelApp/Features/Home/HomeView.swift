import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: AppTab
    @State private var healthModel = AppHealthModel()

    private var recommendedSet: RosarySet {
        RosarySet.recommended()
    }

    var body: some View {
        ThemedScrollView {
            SectionCard {
                PillLabel("marsharbel companion", systemImage: "dot.radiowaves.left.and.right")

                Text("Saint Charbel for prayer, story, and daily stillness.")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("This iPhone app complements marsharbel.com with a focused native experience: a swipeable Saint Charbel storybook, guided Rosary mystery paths, and core prayer texts in one place.")
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 12) {
                    QuickActionButton(
                        title: "Read the Story",
                        subtitle: "Swipe picture book",
                        systemImage: "book.closed.fill"
                    ) {
                        selectedTab = .story
                    }

                    QuickActionButton(
                        title: "Pray the Rosary",
                        subtitle: recommendedSet.schedule,
                        systemImage: recommendedSet.symbolName
                    ) {
                        selectedTab = .rosary
                    }
                }
            }

            SectionCard {
                Text("Saint Charbel at a glance")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    StatTile(title: "Born in Bekaa Kafra", value: "1828")
                    StatTile(title: "Final Mass", value: "1898")
                    StatTile(title: "Canonized", value: "1977")
                }
            }

            NavigationLink {
                RosarySetView(set: recommendedSet)
            } label: {
                SectionCard {
                    PillLabel("Today's recommended mysteries", systemImage: recommendedSet.symbolName)

                    Text(recommendedSet.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(recommendedSet.summary)
                        .font(.body)
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack {
                        Text(recommendedSet.schedule)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.accent(for: recommendedSet))

                        Spacer()

                        Label("Open set", systemImage: "arrow.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
            .buttonStyle(.plain)

            SectionCard {
                Text("Storybook")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Open the Saint Charbel story like a real book and let the narration guide the page turns.")
                    .foregroundStyle(AppTheme.textSecondary)
            }

            NavigationLink {
                StoryBookReaderView(story: StoryCatalog.saintCharbel)
            } label: {
                StoryBookShelfCard(story: StoryCatalog.saintCharbel)
            }
            .buttonStyle(.plain)

            SectionCard {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 8) {
                        PillLabel("Service status", systemImage: healthModel.overallState.systemImage)

                        Text("App health check")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Checks the remote website, story artwork, narration, and rosary audio that this app depends on.")
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer(minLength: 12)

                    Button {
                        Task {
                            await healthModel.refresh()
                        }
                    } label: {
                        Image(systemName: healthModel.isRefreshing ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.gold)
                    }
                    .buttonStyle(.plain)
                    .disabled(healthModel.isRefreshing)
                }

                ForEach(healthModel.results) { result in
                    HealthStatusRow(result: result)
                }

                Text(healthModel.lastChecked.map { "Last checked \(Self.timestampFormatter.string(from: $0))" } ?? "Awaiting first check")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            SectionCard {
                Text("Connected to the website")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("The content in this app is aligned to the existing Saint Charbel website, and rosary audio streams directly from the same media library so updates can stay centralized.")
                    .foregroundStyle(AppTheme.textSecondary)

                Link(destination: URL(string: "https://marsharbel.com")!) {
                    Label("Open marsharbel.com", systemImage: "safari")
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
        .navigationTitle("Saint Charbel")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await healthModel.refreshIfNeeded()
        }
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

private struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(AppTheme.gold)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct HealthStatusRow: View {
    let result: AppHealthCheckResult

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(result.state.fillColor.opacity(0.18))
                    .frame(width: 34, height: 34)

                Image(systemName: result.state.systemImage)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(result.state.fillColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(result.service.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(result.service.detail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)

                Text(result.summary)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(result.state.fillColor)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
}

private extension AppHealthState {
    var systemImage: String {
        switch self {
        case .checking:
            return "clock.badge.questionmark"
        case .healthy:
            return "checkmark.seal.fill"
        case .degraded:
            return "exclamationmark.triangle.fill"
        case .unavailable:
            return "xmark.octagon.fill"
        }
    }

    var fillColor: Color {
        switch self {
        case .checking:
            return AppTheme.gold
        case .healthy:
            return AppTheme.olive
        case .degraded:
            return AppTheme.gold
        case .unavailable:
            return AppTheme.rose
        }
    }
}
