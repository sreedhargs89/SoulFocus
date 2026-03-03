// Color+Hex.swift
// Hex color initialiser. Used by the theme system.

import SwiftUI

extension Color {

    /// Initialise a Color from a CSS-style hex string.
    /// Supports "#RGB", "#RRGGBB", and "#AARRGGBB" formats.
    ///
    /// Usage:
    ///   Color(hex: "#1a1a2e")
    ///   Color(hex: "a8dadc")
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3:  // RGB 12-bit shorthand
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB 24-bit
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB 32-bit
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
