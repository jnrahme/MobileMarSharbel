import SwiftUI

enum AppTheme {
    static let backgroundTop = Color(red: 0.07, green: 0.10, blue: 0.14)
    static let backgroundBottom = Color(red: 0.03, green: 0.05, blue: 0.08)
    static let panel = Color(red: 0.10, green: 0.14, blue: 0.19)
    static let chromeBackground = Color(red: 0.06, green: 0.08, blue: 0.12)
    static let chromeBorder = Color.white.opacity(0.10)
    static let panelBorder = Color.white.opacity(0.12)
    static let textPrimary = Color(red: 0.96, green: 0.94, blue: 0.89)
    static let textSecondary = Color(red: 0.79, green: 0.80, blue: 0.82)
    static let tabInactive = Color(red: 0.72, green: 0.74, blue: 0.78)
    static let gold = Color(red: 0.84, green: 0.72, blue: 0.44)
    static let ember = Color(red: 0.71, green: 0.47, blue: 0.32)
    static let olive = Color(red: 0.48, green: 0.58, blue: 0.40)
    static let rose = Color(red: 0.63, green: 0.38, blue: 0.44)
    static let paper = Color(red: 0.95, green: 0.91, blue: 0.84)
    static let paperShadow = Color(red: 0.83, green: 0.73, blue: 0.58)
    static let ink = Color(red: 0.18, green: 0.18, blue: 0.20)
    static let storyBlue = Color(red: 0.32, green: 0.46, blue: 0.67)
    static let storyBerry = Color(red: 0.65, green: 0.32, blue: 0.39)

    static let backgroundGradient = LinearGradient(
        colors: [backgroundTop, backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let storybookGradient = LinearGradient(
        colors: [
            Color(red: 0.09, green: 0.13, blue: 0.21),
            Color(red: 0.18, green: 0.22, blue: 0.33),
            Color(red: 0.27, green: 0.20, blue: 0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func accent(for set: RosarySet) -> Color {
        switch set {
        case .joyful:
            return gold
        case .luminous:
            return Color(red: 0.56, green: 0.76, blue: 0.78)
        case .sorrowful:
            return rose
        case .glorious:
            return olive
        }
    }

    static func gradient(for set: RosarySet) -> LinearGradient {
        switch set {
        case .joyful:
            return LinearGradient(colors: [gold.opacity(0.7), ember.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .luminous:
            return LinearGradient(colors: [Color(red: 0.54, green: 0.77, blue: 0.80), Color(red: 0.35, green: 0.48, blue: 0.73)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sorrowful:
            return LinearGradient(colors: [rose.opacity(0.82), Color(red: 0.30, green: 0.18, blue: 0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .glorious:
            return LinearGradient(colors: [olive.opacity(0.92), Color(red: 0.29, green: 0.45, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
