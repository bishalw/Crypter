//
//  CoinModel.swift
//  Crypter
//

import Foundation
import SwiftUI

// MARK: - Coin Model

struct CoinModel: Identifiable {
    let id, symbol, name: String
    let image: String
    let currentPrice: Double
    let marketCap, marketCapRank, fullyDilutedValuation: Double?
    let totalVolume, high24H, low24H: Double?
    let priceChange24H, priceChangePercentage24H: Double?
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply, totalSupply, maxSupply, ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl, atlChangePercentage: Double?
    let atlDate: String?
    let lastUpdated: String?
    let sparklineIn7D: SparklineIn7D?
    let priceChangePercentage24HInCurrency: Double?
    let currentHoldings: Double?

    /// Average price paid per coin. `nil` when the basis is unknown, e.g. for
    /// holdings that predate transaction tracking.
    var averageCost: Double? = nil
    
    var price: [Double]? {
        sparklineIn7D?.price
    }
    
    func updateHoldings(amount: Double) -> CoinModel {
        return CoinModel(id: id, symbol: symbol, name: name, image: image, currentPrice: currentPrice, marketCap: marketCap, marketCapRank: marketCapRank, fullyDilutedValuation: fullyDilutedValuation, totalVolume: totalVolume, high24H: high24H, low24H: low24H, priceChange24H: priceChange24H, priceChangePercentage24H: priceChangePercentage24H, marketCapChange24H: marketCapChange24H, marketCapChangePercentage24H: marketCapChangePercentage24H, circulatingSupply: circulatingSupply, totalSupply: totalSupply, maxSupply: maxSupply, ath: ath, athChangePercentage: athChangePercentage, athDate: athDate, atl: atl, atlChangePercentage: atlChangePercentage, atlDate: atlDate, lastUpdated: lastUpdated, sparklineIn7D: sparklineIn7D, priceChangePercentage24HInCurrency: priceChangePercentage24HInCurrency, currentHoldings: amount)
    }
    
    var currentHoldingsValue: Double {
        return (currentHoldings ?? 0) * currentPrice
    }

    var costBasisValue: Double? {
        guard let averageCost, let currentHoldings else { return nil }
        return averageCost * currentHoldings
    }

    var totalProfit: Double? {
        guard let costBasisValue else { return nil }
        return currentHoldingsValue - costBasisValue
    }

    var totalProfitPercentage: Double? {
        guard let costBasisValue, costBasisValue > 0, let totalProfit else { return nil }
        return (totalProfit / costBasisValue) * 100
    }

    func updatePosition(amount: Double, averageCost: Double?) -> CoinModel {
        var updated = updateHoldings(amount: amount)
        updated.averageCost = averageCost
        return updated
    }
    
    var rank: Int {
        return Int(marketCapRank ?? 0)
    }
}

// MARK: - Chart Models

enum ChartTimeRange: String, CaseIterable, Identifiable {
    case day = "24H"
    case week = "7D"
    case month = "30D"
    case sixMonths = "6M"
    case year = "1Y"
    case all = "ALL"

    var id: String { rawValue }

    static var availableCases: [ChartTimeRange] {
        #if DEBUG
        return [.day, .week, .month, .sixMonths, .year, .all]
        #else
        return [.day, .week, .month, .sixMonths, .year]
        #endif
    }
}

enum ChartReferenceLine: String, CaseIterable, Identifiable {
    case none = "None"
    case startPrice = "Start"
    case currentPrice = "Current"
    case ath = "ATH"
    case high24h = "24h High"
    case low24h = "24h Low"

    var id: String { rawValue }
}

struct ChartPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let price: Double
}

enum SparklineStyle {
    static func lineColor(for data: [Double]) -> Color {
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        return priceChange >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    static func yScaleDomain(for data: [Double]) -> ClosedRange<Double> {
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

struct SparklineIn7D: Codable {
    let price: [Double]?
}

extension CoinModel {
    static func mockCoins() -> [CoinModel] {
        let coin = CoinModel(
           id: "bitcoin",
           symbol: "btc",
           name: "Bitcoin",
           image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
           currentPrice: 61408,
           marketCap: 1141731099010,
           marketCapRank: 1,
           fullyDilutedValuation: 1285385611303,
           totalVolume: 67190952980,
           high24H: 61712,
           low24H: 56220,
           priceChange24H: 3952.64,
           priceChangePercentage24H: 6.87944,
           marketCapChange24H: 72110681879,
           marketCapChangePercentage24H: 6.74171,
           circulatingSupply: 18653043,
           totalSupply: 21000000,
           maxSupply: 21000000,
           ath: 61712,
           athChangePercentage: -0.97589,
           athDate: "2021-03-13T20:49:26.606Z",
           atl: 67.81,
           atlChangePercentage: 90020.24075,
           atlDate: "2013-07-06T00:00:00.000Z",
           lastUpdated: "2021-03-13T23:18:10.268Z",
           sparklineIn7D: SparklineIn7D(price: [54019.26, 53718.06, 53677.13]),
           priceChangePercentage24HInCurrency: 3952.64,
           currentHoldings: 1.5)
        
        let coin2 = CoinModel(
           id: "tether",
           symbol: "usdt",
           name: "Tether",
           image: "https://assets.coingecko.com/coins/images/325/large/tether.png?1594008143",
           currentPrice: 1.0,
           marketCap: 60000000000,
           marketCapRank: 3,
           fullyDilutedValuation: 60000000000,
           totalVolume: 80000000000,
           high24H: 1.01,
           low24H: 0.99,
           priceChange24H: 0.001,
           priceChangePercentage24H: 0.1,
           marketCapChange24H: 1000000,
           marketCapChangePercentage24H: 0.05,
           circulatingSupply: 60000000000,
           totalSupply: 60000000000,
           maxSupply: 60000000000,
           ath: 1.21,
           athChangePercentage: -20.0,
           athDate: "2018-07-24T00:00:00.000Z",
           atl: 0.57,
           atlChangePercentage: 75.0,
           atlDate: "2015-03-02T00:00:00.000Z",
           lastUpdated: "2021-03-13T23:18:10.268Z",
           sparklineIn7D: SparklineIn7D(price: [1.0, 1.0, 1.0]),
           priceChangePercentage24HInCurrency: 0.001,
           currentHoldings: 1000.0)
           
        return [coin, coin2]
    }
}
