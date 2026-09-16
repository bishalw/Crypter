//
//  Color.swift
//  Crypter
//
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RGBA (32-bit)
            (a, r, g, b) = (int & 0xFF, int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColorTheme {


    // MARK: - Brand Colors

    /// Primary brand color
    let brandPrimary = Color(hex: "#9D8CFF")

    /// Tinted brand fill for selected rows, chips and badges
    let brandSoft = Color(hex: "#9D8CFF24")

    // MARK: - Surface Colors

    /// Main background for the app
    let surfaceBackground = Color(hex: "#0A0B0E")

    /// Secondary background for cards and interactive elements
    let surfaceSecondary = Color(hex: "#15171C")

    /// Raised background for controls sitting on a card
    let surfaceTertiary = Color(hex: "#1D2027")

    /// Top stop of the brand-tinted card wash used on the global market card
    let surfaceBrandTint = Color(hex: "#1C1935")

    /// Subtle divider and border color
    let borderSubtle = Color(hex: "#262A33")

    // MARK: - Text Colors

    /// Standard high-contrast text
    let textPrimary = Color(hex: "#F3F4F6")

    /// Muted text for labels and captions
    let textSecondary = Color(hex: "#8B92A0")

    /// Faint text for ranks, column headers and footnotes
    let textTertiary = Color(hex: "#5B6170")

    // MARK: - Status Colors

    /// Success / Positive Trend
    let statusSuccess = Color(hex: "#34D399")

    /// Tinted success fill
    let statusSuccessSoft = Color(hex: "#34D3991F")

    /// Danger / Negative Trend
    let statusDanger = Color(hex: "#F87171")

    /// Tinted danger fill
    let statusDangerSoft = Color(hex: "#F871711F")

    /// Trending / hot accent
    let statusHot = Color(hex: "#FB923C")
}
