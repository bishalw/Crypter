//
//  DisplayCurrency.swift
//  Crypter
//

import Foundation

enum DisplayCurrency: String, CaseIterable, Identifiable {
    case usd, eur, gbp, jpy, cad, aud, inr

    static let storageKey = "displayCurrency"

    /// Read directly rather than injected, because the number formatters are
    /// static helpers on Double with nowhere to inject into.
    static var current: DisplayCurrency {
        DisplayCurrency(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .usd
    }

    var id: String { rawValue }

    /// What CoinGecko expects for vs_currency.
    var apiCode: String { rawValue }

    var code: String { rawValue.uppercased() }

    var symbol: String {
        switch self {
        case .usd, .cad, .aud: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .inr: return "₹"
        }
    }

    var title: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .inr: return "Indian Rupee"
        }
    }

    /// A locale that formats this currency the way its users expect.
    var formattingLocale: Locale {
        switch self {
        case .usd: return Locale(identifier: "en_US")
        case .eur: return Locale(identifier: "de_DE")
        case .gbp: return Locale(identifier: "en_GB")
        case .jpy: return Locale(identifier: "ja_JP")
        case .cad: return Locale(identifier: "en_CA")
        case .aud: return Locale(identifier: "en_AU")
        case .inr: return Locale(identifier: "en_IN")
        }
    }
}
