//
//  ChartModels.swift
//  Crypter
//

import Foundation
import SwiftUI

// MARK: - Chart Models

public enum ChartTimeRange: String, CaseIterable, Identifiable {
    case day = "24H"
    case week = "7D"
    case month = "30D"
    case year = "1Y"
    case all = "ALL"

    public var id: String { rawValue }
}

public enum ChartReferenceLine: String, CaseIterable, Identifiable {
    case none = "None"
    case startPrice = "Start"
    case currentPrice = "Current"
    case ath = "ATH"
    case high24h = "24h High"
    case low24h = "24h Low"

    public var id: String { rawValue }
}

public struct ChartPoint: Identifiable, Equatable {
    public let id = UUID()
    public let date: Date
    public let price: Double
}

// MARK: - Shared Sparkline Helpers

public enum SparklineStyle {
    public static func lineColor(for data: [Double]) -> Color {
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        return priceChange >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    public static func yScaleDomain(for data: [Double]) -> ClosedRange<Double> {
        guard let minValue = data.min(), let maxValue = data.max() else {
            return 0...1
        }

        if minValue == maxValue {
            let inset = Swift.max(1, abs(maxValue) * 0.02)
            return (minValue - inset)...(maxValue + inset)
        }

        let padding = Swift.max((maxValue - minValue) * 0.12, 1)
        return (minValue - padding)...(maxValue + padding)
    }
}
