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
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
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
    
    /// Primary brand color (Electric Indigo)
    let brandPrimary = Color(hex: "#5271FF")
    
    // MARK: - Surface Colors
    
    /// Main background for the app (Deep Charcoal)
    let surfaceBackground = Color(hex: "#0B0E11")
    
    /// Secondary background for cards and interactive elements
    let surfaceSecondary = Color(hex: "#1E2329")
    
    /// Subtle divider and border color
    let borderSubtle = Color.white.opacity(0.1)
    
    // MARK: - Text Colors
    
    /// Standard high-contrast text
    let textPrimary = Color.white
    
    /// Muted text for labels and captions
    let textSecondary = Color(hex: "#848E9C")
    
    // MARK: - Status Colors
    
    /// Success / Positive Trend (Mint Emerald)
    let statusSuccess = Color(hex: "#00FFA3")
    
    /// Danger / Negative Trend (Vibrant Coral)
    let statusDanger = Color(hex: "#FF5C5C")
}
