// AppTheme.swift
// Theme protocol + registry. All 5 themes conform to AppTheme.
// Injected via SwiftUI Environment so every view gets it automatically.

import SwiftUI

// MARK: - Protocol

protocol AppTheme {
    var id: AppThemeID { get }
    var displayName: String { get }
    var backgroundGradient: LinearGradient { get }
    var accentColor: Color { get }
    var primaryText: Color { get }
    var secondaryText: Color { get }
    var cardBackground: Color { get }
    var buttonBackground: Color { get }
    var tabBarBackground: Color { get }
    var timerRingColor: Color { get }
}

// MARK: - Theme ID

enum AppThemeID: String, CaseIterable, Identifiable {
    case calm     = "calm"
    case sunrise  = "sunrise"
    case nightSky = "nightSky"
    case forest   = "forest"
    case saffron  = "saffron"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calm:     return "Calm"
        case .sunrise:  return "Sunrise"
        case .nightSky: return "Night Sky"
        case .forest:   return "Forest"
        case .saffron:  return "Saffron"
        }
    }

    var theme: any AppTheme {
        switch self {
        case .calm:     return CalmTheme()
        case .sunrise:  return SunriseTheme()
        case .nightSky: return NightSkyTheme()
        case .forest:   return ForestTheme()
        case .saffron:  return SaffronTheme()
        }
    }

    /// Whether this theme is locked behind premium.
    var requiresPremium: Bool {
        self != .calm  // Calm is the free default theme
    }
}

// MARK: - Environment Key

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any AppTheme = CalmTheme()
}

extension EnvironmentValues {
    var sfTheme: any AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    /// Inject a theme into the SwiftUI environment.
    func sfTheme(_ theme: any AppTheme) -> some View {
        environment(\.sfTheme, theme)
    }
}
