//
//  TrendingCoinModel.swift
//  Crypter
//

import Foundation

struct TrendingCoinModel: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let imageURL: String
    let priceChangePercentage24H: Double?
}

extension TrendingCoinModel {
    static func mockTrendingCoins() -> [TrendingCoinModel] {
        [
            TrendingCoinModel(id: "sui", name: "Sui", symbol: "SUI", imageURL: "", priceChangePercentage24H: 12.4),
            TrendingCoinModel(id: "hyperliquid", name: "Hyperliquid", symbol: "HYPE", imageURL: "", priceChangePercentage24H: 8.9),
            TrendingCoinModel(id: "pudgy-penguins", name: "Pengu", symbol: "PENGU", imageURL: "", priceChangePercentage24H: -3.2)
        ]
    }
}
