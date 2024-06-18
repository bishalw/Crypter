//
//  CoinModel.swift
//  Crypter
//
//

import Foundation


struct CoinModel: Identifiable{
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
    let price: [Double]?
    let priceChangePercentage24HInCurrency: Double?
    let currentHoldings: Double?
    
    
    
    func updateHoldings(amount: Double) -> CoinModel {
        return CoinModel(id: id, symbol: symbol, name: name, image: image, currentPrice: currentPrice, marketCap: marketCap, marketCapRank: marketCapRank, fullyDilutedValuation: fullyDilutedValuation, totalVolume: totalVolume, high24H: high24H, low24H: low24H, priceChange24H: priceChange24H, priceChangePercentage24H: priceChangePercentage24H, marketCapChange24H: marketCapChange24H, marketCapChangePercentage24H: marketCapChangePercentage24H, circulatingSupply: circulatingSupply, totalSupply: totalSupply, maxSupply: maxSupply, ath: ath, athChangePercentage: athChangePercentage, athDate: athDate, atl: atl, atlChangePercentage: atlChangePercentage, atlDate: atlDate, lastUpdated: lastUpdated, price: price, priceChangePercentage24HInCurrency: priceChangePercentage24H, currentHoldings: amount)
    }
    
    var currentHoldingsValue: Double {
        return (currentHoldings ?? 0) * currentPrice
    }
    
    var rank: Int{
        return Int(marketCapRank ?? 0)
    }
    
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
           price: [
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

           ],
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
           price: [
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

           ],
           priceChangePercentage24HInCurrency: 3952.64,
           currentHoldings: 1.5)
        return [coin,coin2]
    }
}
