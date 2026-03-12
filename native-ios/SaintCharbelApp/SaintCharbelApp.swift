import SwiftUI
import UIKit

@main
struct SaintCharbelApp: App {
    @State private var audioPlayer = AudioPlayerModel()

    init() {
        configureAppChrome()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(audioPlayer)
        }
    }

    private func configureAppChrome() {
        let selectedColor = UIColor(red: 0.84, green: 0.72, blue: 0.44, alpha: 1)
        let inactiveColor = UIColor(red: 0.72, green: 0.74, blue: 0.78, alpha: 1)
        let titleColor = UIColor(red: 0.96, green: 0.94, blue: 0.89, alpha: 1)
        let tabBackground = UIColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 0.98)
        let borderColor = UIColor(white: 1, alpha: 0.10)

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = tabBackground
        tabAppearance.shadowColor = borderColor

        [tabAppearance.stackedLayoutAppearance, tabAppearance.inlineLayoutAppearance, tabAppearance.compactInlineLayoutAppearance]
            .forEach { itemAppearance in
                itemAppearance.normal.iconColor = inactiveColor
                itemAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
                itemAppearance.selected.iconColor = selectedColor
                itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            }

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = inactiveColor

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        navigationAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: selectedColor]
        navigationAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: selectedColor]

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().tintColor = selectedColor
    }
}
