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

struct GlobalData: Codable {
    let data: MarketDataModel?
}

struct MarketDataModel: Codable {

    let totalMarketCap, totalVolume, marketCapPercentage: [String: Double]
    let marketCapChangePercentage24HUsd: Double
   
    
    enum CodingKeys: String, CodingKey {
        case totalMarketCap = "total_market_cap"
        case totalVolume = "total_volume"
        case marketCapPercentage = "market_cap_percentage"
        case marketCapChangePercentage24HUsd = "market_cap_change_percentage_24h_usd"
    }
    
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
}

extension MarketDataModel {
    static func mockMarketDataModel() -> MarketDataModel  {
        return MarketDataModel(
            totalMarketCap:[
                "active_cryptocurrencies": 12916,
                "upcoming_icos": 0,
                "ongoing_icos": 49,
                "ended_icos": 3376,
                "markets": 568,
            ],
            totalVolume: [
                "btc": 4284633.494789662,
                "xau": 48204642.314971656,
                "bits": 4284633494789.6616,
                "sats": 428463349478966.2
            ],
            marketCapPercentage:[
                "btc": 35.99775935166138,
                "eth": 19.24582082522093,
                "usdt": 6.6160097306404,
                "usdc": 5.05967530187105,
                "bnb": 4.470148867351053,
                "busd": 1.951897673032006
            ],
            marketCapChangePercentage24HUsd: 2.556299656001906)
    }
}

