//
//  CoinModel.swift
//  Crypter
//
//

import Foundation
// CoinGecko API info

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
        19849.56117005255,
        19113.688678973267,
        19266.868000576575,
        19631.20899596838,
        19507.710566736307,
        19623.31809258988,
        19912.101239181808,
        19850.276980152932,
        19672.860429815875,
        19678.422458477453,
        19871.55142565721,
        19844.246944933417,
        20204.492325613934,
        20328.29108932613,
        20258.446832144553,
        20250.140027792808,
        20237.684522206786,
        20114.127749304003,
        20136.829538045826,
        20023.219782736305,
        20000.724162810176,
        19826.907217846827,
        19805.833635211282,
        19788.63264166262,
        19748.348514149035,
        19798.531322666873,
        19764.689094447178,
        19831.73431602579,
        20398.675088720574,
        20228.6306265231,
        20599.939912611324,
        20697.65730744682,
        20648.25729160605,
        20643.70957065769,
        20487.414521882423,
        20499.224346934323,
        20594.75461740139,
        20435.357940523878,
        20490.916825979682,
        20554.258067578456,
        20531.27804653961,
        20552.53528003382,
        20658.432469693173,
        20614.13635025124,
        20808.005432830385,
        20862.734547704462,
        20916.871900730388,
        20833.082879851594,
        20784.539646264635,
        20875.192686822396,
        20809.54294937471,
        20904.286433466532,
        20845.861947356374,
        20698.566856062236,
        20802.392140771397,
        21028.019836460702,
        21135.784032550167,
        20935.132283530755,
        20952.99637132786,
        20889.314292097766,
        20794.811981436706,
        20727.08216015578,
        20714.623356244272,
        20693.187752465503,
        20744.0278492535,
        20742.230093060556,
        20697.411831421952,
        20536.978833174362,
        20522.749339726004,
        20598.692993462493,
        20610.661858977386,
        20631.678343941872,
        20643.433414462812,
        20659.629522066014,
        20786.65765112151,
        20799.241514273835,
        20931.541258324312,
        21382.869584516186,
        21399.149590512203
        21267.176613857075,
        21225.275421739167,
        21112.946209610458,
        21232.890055531167,
        21227.184606050185,
        21193.08334336837,
        21286.111019297405,
        21139.114844826712,
        21159.815096431652,
        21319.018836724095,
        21265.153855771445,
        21351.3788689518,
        21465.784310299325,
        21509.626028828054,
        21394.693503712344,
        21349.85644354805,
        21345.297884751904,
        21346.775742817284,
        21391.588369387344,
        21204.4636449447,
        21228.882146750097,
        21153.486981925176,
        21157.356900860188,
        20935.72186429424,
        20978.942991562133,
        21030.027782351386,
        20940.404419270526,
        21004.01890464112,
        20995.891184502085,
        20802.939872166535,
        20806.23426191069,
        20989.004225317207,
        21134.547493689144,
        21298.818223121045,
        21267.90491335803,
        21818.694353786872,
        22290.463752551517,
        22289.34318508772,
        22204.5684511686,
        22283.233554370676,
        22212.544695426215,
        22097.815229897475,
        22130.37068127463,
        22140.103498438293,
        22086.42361301151,
        22343.508744451945,
        22157.01360130391,
        21981.811368412706,
        21894.60243177206,
        21588.2994046311,
        21504.880600626013,
        21702.15743148427,
        21784.494532678902,
        22395.365383103952,
        22403.43968420375,
        22109.908339652444,
        22076.85594416673,
        21896.990867396315,
        21921.71509997961,
        22043.2756072838,
        21804.297159152666,
        21766.862634047677,
        21874.218130939098,
        21927.001888395618,
        22036.58470789851,
        22018.35285739783,
        22179.975818045663,
        22160.95553979459,
        22525.43356720625,
        23122.790839010988,
        23289.455562540406,
        23304.423473312974,
        23394.139361985206,
        23445.835506804622,
        23240.388132797627,
        23654.858145187776,
        23461.9839189125,
        23366.90769792785,
        22993.315869564274,
        23278.8512553142,
        23441.169137635232,
        23437.865337434596,
        23388.391425527912,
        23504.684734855415,
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
