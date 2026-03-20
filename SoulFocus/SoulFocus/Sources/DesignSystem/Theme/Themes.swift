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

// MARK: - Calm / Sacred Dawn (Free Default)
// Light-first. Warm ivory ground + saffron fire accent.
// The color of morning light through temple stone.

struct CalmTheme: AppTheme {
    let id: AppThemeID = .calm
    let displayName    = "Sacred Dawn"

    var backgroundGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 1.00, green: 0.98, blue: 0.93), location: 0.00), // ivory
                .init(color: Color(red: 0.99, green: 0.94, blue: 0.84), location: 0.50), // amber cream
                .init(color: Color(red: 0.97, green: 0.88, blue: 0.74), location: 1.00)  // golden champagne
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    var accentColor:      Color { Color(red: 0.96, green: 0.58, blue: 0.11) } // saffron fire
    var primaryText:      Color { Color(red: 0.07, green: 0.04, blue: 0.01) } // near-black warm
    var secondaryText:    Color { Color(red: 0.28, green: 0.18, blue: 0.06) } // dark warm brown
    var cardBackground:   Color { Color(red: 1.00, green: 0.99, blue: 0.96) } // warm white
    var buttonBackground: Color { Color(red: 0.96, green: 0.58, blue: 0.11) } // saffron
    var tabBarBackground: Color { Color(red: 0.99, green: 0.97, blue: 0.92) } // warm ivory
    var timerRingColor:   Color { Color(red: 0.96, green: 0.58, blue: 0.11) } // saffron
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
