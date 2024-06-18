//
//  GlobalDataDTO.swift
//  Crypter
//
//

import Foundation

struct GlobalDataDTO: Codable {
    let data: MarketData?
}

extension GlobalDataDTO {
    struct MarketData: Codable {
        
        let totalMarketCap, totalVolume, marketCapPercentage: [String: Double]
        let marketCapChangePercentage24HUsd: Double
        
        
        enum CodingKeys: String, CodingKey {
            case totalMarketCap = "total_market_cap"
            case totalVolume = "total_volume"
            case marketCapPercentage = "market_cap_percentage"
            case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
        }
        
    }
    
}

    
