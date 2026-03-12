import SwiftUI

enum AppTab: Hashable {
    case home
    case story
    case rosary
}

struct ContentView: View {
    @Environment(AudioPlayerModel.self) private var audioPlayer
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(selectedTab: $selectedTab)
            }
            .modifier(RootNavigationChrome())
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack {
                StoryLibraryView()
            }
            .modifier(RootNavigationChrome())
            .tabItem {
                Label("Story", systemImage: "book.closed.fill")
            }
            .tag(AppTab.story)

            NavigationStack {
                RosaryHubView()
            }
            .modifier(RootNavigationChrome())
            .tabItem {
                Label("Rosary", systemImage: "sparkles")
            }
            .tag(AppTab.rosary)
        }
        .tint(AppTheme.gold)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(AppTheme.chromeBackground, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            if audioPlayer.hasActiveTrack {
                MiniPlayerView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
    }
}

private struct RootNavigationChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(AppTheme.chromeBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    ContentView()
        .environment(AudioPlayerModel())
}
