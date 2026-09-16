//
//  TrendingDTO.swift
//  Crypter
//

import Foundation

struct TrendingDTO: Codable {
    let coins: [CoinItemWrapper]
}

extension TrendingDTO {
    struct CoinItemWrapper: Codable {
        let item: Item
    }

    struct Item: Codable {
        let id, name, symbol: String
        let small: String
        let data: ItemData?
    }

    struct ItemData: Codable {
        let priceChangePercentage24H: PriceChangePercentage24H?

        enum CodingKeys: String, CodingKey {
            case priceChangePercentage24H = "price_change_percentage_24h"
        }
    }

    struct PriceChangePercentage24H: Codable {
        let usd: Double?
    }
}
