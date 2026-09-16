//
//  MarketDataModel.swift
//  Crypter
//


import Foundation

// Coin Gecko API response : MarketDataModel
/*
 
 https://api.coingecko.com/api/v3/global
 
 {
   "data": {
     "active_cryptocurrencies": 12916,
     "upcoming_icos": 0,
     "ongoing_icos": 49,
     "ended_icos": 3376,
     "markets": 568,
     "total_market_cap": {
       "btc": 53183637.93972199,
       "eth": 626051591.3994783,
       "ltc": 17840130522.012856,
     },
     "total_volume": {
       "btc": 4284633.494789662,
       "xau": 48204642.314971656,
       "bits": 4284633494789.6616,
       "sats": 428463349478966.2
     },
     "market_cap_percentage": {
       "btc": 35.99775935166138,
       "eth": 19.24582082522093,
       "usdt": 6.6160097306404,
       "usdc": 5.05967530187105,
       "bnb": 4.470148867351053,
       "busd": 1.951897673032006,
     },
     "market_cap_change_percentage_24h_usd": 2.556299656001906,
     "updated_at": 1662658090
   }
 }
 
*/

struct MarketDataModel {
    //TODO: fix it with DTO
    let totalMarketCap, totalVolume, marketCapPercentage: [String: Double]
    let marketCapChangePercentage24HUsd: Double
   

    var marketCap: String {
        if let item = totalMarketCap.first(where: { $0.key == "usd" }){
            return "$" + item.value.formattedWithAbbreviations()
        }
        return ""
    }
    
    var volume: String {
        if let item = totalVolume.first(where: { $0.key == "usd" }) {
            return "$" +  item.value.formattedWithAbbreviations()
        }
        return ""
    }
    
    var btcDominance: String {
        if let item = marketCapPercentage.first(where: { $0.key == "btc"}) {
            return item.value.asPercentString()
        }
        return ""
    }

    var ethDominance: String {
        if let item = marketCapPercentage.first(where: { $0.key == "eth"}) {
            return item.value.asPercentString()
        }
        return ""
    }

    func asHomeStatistics() -> [StatisticModel] {
        [
            StatisticModel(title: "Market Cap", value: marketCap, percentageChange: marketCapChangePercentage24HUsd),
            StatisticModel(title: "24h Volume", value: volume),
            StatisticModel(title: "BTC Dominance", value: btcDominance),
            StatisticModel(title: "ETH Dominance", value: ethDominance)
        ]
    }
}

extension MarketDataModel {
    static func mockMarketDataModel() -> MarketDataModel  {
        return MarketDataModel(
            totalMarketCap:[
                "usd": 3_940_000_000_000,
                "btc": 53183637.93972199,
                "eth": 626051591.3994783
            ],
            totalVolume: [
                "usd": 142_600_000_000,
                "btc": 4284633.494789662
            ],
            marketCapPercentage:[
                "btc": 57.2,
                "eth": 13.1,
                "usdt": 6.6160097306404,
                "usdc": 5.05967530187105,
                "bnb": 4.470148867351053,
                "busd": 1.951897673032006
            ],
            marketCapChangePercentage24HUsd: 1.82)
    }
}

