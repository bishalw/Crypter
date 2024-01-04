//
//  CoinModel.swift
//  Crypter
//
//

import Foundation

// CoinGecko API response: Coin Model info
/*
    URL:
https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h
  
    JSON Response
 {
    "id": "bitcoin",
    "symbol": "btc",
    "name": "Bitcoin",
    "image": "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
    "current_price": 23848,
    "market_cap": 455458589461,
    "market_cap_rank": 1,
    "fully_diluted_valuation": 500803535568,
    "total_volume": 44109094184,
    "high_24h": 24189,
    "low_24h": 22993,
    "price_change_24h": 521.49,
    "price_change_percentage_24h": 2.23562,
    "market_cap_change_24h": 12482370229,
    "market_cap_change_percentage_24h": 2.81784,
    "circulating_supply": 19098568,
    "total_supply": 21000000,
    "max_supply": 21000000,
    "ath": 69045,
    "ath_change_percentage": -65.4712,
    "ath_date": "2021-11-10T14:24:11.849Z",
    "atl": 67.81,
    "atl_change_percentage": 35058.06373,
    "atl_date": "2013-07-06T00:00:00.000Z",
    "roi": null,
    "last_updated": "2022-07-20T16:40:06.970Z",
    "sparkline_in_7d": {
      "price": [
        23777.91588984244,
        23542.60744576451,
        23420.86442043315,
        23553.562599212866,
        23672.9988281348
      ]
    },
    "price_change_percentage_24h_in_currency": 2.2356173347871624
  }
 */
struct CoinModel: Identifiable, Codable{
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
    
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d"
        case priceChangePercentage24HInCurrency = "price_change_percentage_24h_in_currency"
        case currentHoldings 
    }
    
    func updateHoldings(amount: Double) -> CoinModel {
        return CoinModel(id: id, symbol: symbol, name: name, image: image, currentPrice: currentPrice, marketCap: marketCap, marketCapRank: marketCapRank, fullyDilutedValuation: fullyDilutedValuation, totalVolume: totalVolume, high24H: high24H, low24H: low24H, priceChange24H: priceChange24H, priceChangePercentage24H: priceChangePercentage24H, marketCapChange24H: marketCapChange24H, marketCapChangePercentage24H: marketCapChangePercentage24H, circulatingSupply: circulatingSupply, totalSupply: totalSupply, maxSupply: maxSupply, ath: ath, athChangePercentage: athChangePercentage, athDate: athDate, atl: atl, atlChangePercentage: atlChangePercentage, atlDate: atlDate, lastUpdated: lastUpdated, sparklineIn7D: sparklineIn7D, priceChangePercentage24HInCurrency: priceChangePercentage24H, currentHoldings: amount)
    }
    
    var currentHoldingsValue: Double {
        return (currentHoldings ?? 0) * currentPrice
    }
    
    var rank: Int{
        return Int(marketCapRank ?? 0)
    }
    
}

// MARK: - SparklineIn7D
struct SparklineIn7D: Codable {
    let price: [Double]?
}
