//
//  CoinDetailModel.swift
//  Crypter
//
//

import Foundation

// API endpoint
/*
 
 JSON
 
 URL:
    https://api.coingecko.com/api/v3/coins/bitcoin?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false
 Response:
 
 */
struct CoinDetailModel: Codable {
    let id, symbol, name: String?
    let blockTimeInMinutes: Int?
    let hashingAlgorithm: String?
    let description: Description?
    let links: Links?

    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, description, links
        case blockTimeInMinutes = "block_time_in_minutes"
        case hashingAlgorithm = "hashing_algorithm"
        
    }
    
    var readableDescription: String? {
        return description?.en?.removingHTMLOccurances
    }
}

struct Links: Codable {
    let homepage: [String]?
    let subredditURL: String?

    enum CodingKeys: String, CodingKey {
        case homepage
        case subredditURL = "subreddit_url"
   
    }
}

struct Description: Codable {
    let en: String?
}

extension CoinDetailModel {
    
    static func mockCoinDetails(for coin: CoinModel) -> CoinDetailModel {
        return CoinDetailModel(id: "12", symbol: "BTC", name: "Bitcoin", blockTimeInMinutes: 25, hashingAlgorithm: "SHA-256", description: .init(en: "Lorem ipsum coinDsijfljklafdsakladskf"), links: .init(homepage: ["fjldsakf","lkfjlsdajfasd"], subredditURL: "reddit.com/jf"))
    }
}

