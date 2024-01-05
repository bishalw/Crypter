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
           sparklineIn7D: SparklineIn7D(price: [
               54019.26878317463,
               53718.060935791524,
               53677.12968669343,
               53848.3814432924,
               53561.593235320615,
               53456.0913723206,
               53888.97184353125,
               54796.37233913172,
               54593.507358383504,
               54582.558599307624,
               54635.7248282177,
               54772.612788430226,
               54954.0493828267,
               54910.13413954234,
               54778.58411728141,
               55027.87934987173,
               55473.0657777974,
               54696.044114623706,

           ]),
           priceChangePercentage24HInCurrency: 3952.64,
           currentHoldings: 1.5)
        let coin2 = CoinModel(
           id: "tether",
           symbol: "TH",
           name: "Tether",
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
           sparklineIn7D: SparklineIn7D(price: [
               54019.26878317463,
               53718.060935791524,
               53677.12968669343,
               53848.3814432924,
               53561.593235320615,
               53456.0913723206,
               53888.97184353125,
               54796.37233913172,
               54593.507358383504,
               54582.558599307624,
               54635.7248282177,
               54772.612788430226,
               54954.0493828267,
               54910.13413954234,
               54778.58411728141,
               55027.87934987173,
               55473.0657777974,
               54696.044114623706,

           ]),
           priceChangePercentage24HInCurrency: 3952.64,
           currentHoldings: 1.5)
        return [coin,coin2]
    }
}
