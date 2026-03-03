// Themes.swift
// All 5 SoulFocus themes. Add more here in future updates.
//
// Palette guide:
//  calm     — Deep navy / teal tones.   Peaceful, default.
//  sunrise  — Warm oranges and purples. Morning energy.
//  nightSky — Near-black / indigo.      Deep meditation.
//  forest   — Deep greens.              Grounded, earthy.
//  saffron  — Amber / gold.             Devotional, prayer.

import SwiftUI

// MARK: - Calm (Free Default)

struct CalmTheme: AppTheme {
    let id: AppThemeID = .calm
    let displayName    = "Calm"

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e"), Color(hex: "#0f3460")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var accentColor:      Color { Color(hex: "#a8dadc") }
    var primaryText:      Color { .white }
    var secondaryText:    Color { Color.white.opacity(0.65) }
    var cardBackground:   Color { Color.white.opacity(0.08) }
    var buttonBackground: Color { Color(hex: "#a8dadc") }
    var tabBarBackground: Color { Color(hex: "#1a1a2e") }
    var timerRingColor:   Color { Color(hex: "#a8dadc") }
}

// MARK: - Sunrise (Premium)

struct SunriseTheme: AppTheme {
    let id: AppThemeID = .sunrise
    let displayName    = "Sunrise"

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#2d1b69"), Color(hex: "#7b2d8b"), Color(hex: "#e07b54")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    var accentColor:      Color { Color(hex: "#ffd89b") }
    var primaryText:      Color { .white }
    var secondaryText:    Color { Color.white.opacity(0.7) }
    var cardBackground:   Color { Color.white.opacity(0.1) }
    var buttonBackground: Color { Color(hex: "#e07b54") }
    var tabBarBackground: Color { Color(hex: "#2d1b69") }
    var timerRingColor:   Color { Color(hex: "#ffd89b") }
}

// MARK: - Night Sky (Premium)

struct NightSkyTheme: AppTheme {
    let id: AppThemeID = .nightSky
    let displayName    = "Night Sky"

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#0a0a0a"), Color(hex: "#0d0d2b"), Color(hex: "#1a0a4a")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    var accentColor:      Color { Color(hex: "#7b61ff") }
    var primaryText:      Color { .white }
    var secondaryText:    Color { Color.white.opacity(0.55) }
    var cardBackground:   Color { Color.white.opacity(0.06) }
    var buttonBackground: Color { Color(hex: "#7b61ff") }
    var tabBarBackground: Color { Color(hex: "#0a0a0a") }
    var timerRingColor:   Color { Color(hex: "#c4b5fd") }
}

// MARK: - Forest (Premium)

struct ForestTheme: AppTheme {
    let id: AppThemeID = .forest
    let displayName    = "Forest"

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#1a2e1a"), Color(hex: "#2d4a2d"), Color(hex: "#1e3a1e")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var accentColor:      Color { Color(hex: "#86efac") }
    var primaryText:      Color { .white }
    var secondaryText:    Color { Color.white.opacity(0.65) }
    var cardBackground:   Color { Color.white.opacity(0.08) }
    var buttonBackground: Color { Color(hex: "#4ade80") }
    var tabBarBackground: Color { Color(hex: "#1a2e1a") }
    var timerRingColor:   Color { Color(hex: "#86efac") }
}

// MARK: - Saffron (Premium)

struct SaffronTheme: AppTheme {
    let id: AppThemeID = .saffron
    let displayName    = "Saffron"

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#2e1a00"), Color(hex: "#7a3b00"), Color(hex: "#bf6900")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    var accentColor:      Color { Color(hex: "#fbbf24") }
    var primaryText:      Color { .white }
    var secondaryText:    Color { Color.white.opacity(0.7) }
    var cardBackground:   Color { Color.white.opacity(0.1) }
    var buttonBackground: Color { Color(hex: "#f59e0b") }
    var tabBarBackground: Color { Color(hex: "#2e1a00") }
    var timerRingColor:   Color { Color(hex: "#fbbf24") }
}
