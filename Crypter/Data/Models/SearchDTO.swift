//
//  SearchDTO.swift
//  Crypter
//

import Foundation

/// CoinGecko's /search response. It covers every listed coin, unlike the
/// markets endpoint, but carries no prices — those are fetched separately.
struct SearchDTO: Codable {
    let coins: [Coin]

    struct Coin: Codable {
        let id: String
        let name: String
        let symbol: String
        let marketCapRank: Int?

        enum CodingKeys: String, CodingKey {
            case id, name, symbol
            case marketCapRank = "market_cap_rank"
        }
    }

    func rankedIDs(limit: Int) -> [String] {
        let ranked = coins
            .filter { $0.marketCapRank != nil }
            .sorted { ($0.marketCapRank ?? .max) < ($1.marketCapRank ?? .max) }

        let unranked = coins.filter { $0.marketCapRank == nil }

        return (ranked + unranked).prefix(limit).map { $0.id }
    }
}
