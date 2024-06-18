//
//  CoinDTO+DomainMapper.swift
//  Crypter
//
//

import Foundation
extension CoinDTO: DomainMapper {
    
    func toDomain() -> CoinModel {
        CoinModel(id: id, symbol: symbol, name: name, image: image, currentPrice: currentPrice, marketCap: marketCap, marketCapRank: marketCapRank, fullyDilutedValuation: fullyDilutedValuation, totalVolume: totalVolume, high24H: high24H, low24H: low24H, priceChange24H: priceChange24H, priceChangePercentage24H: priceChangePercentage24H, marketCapChange24H: marketCapChange24H, marketCapChangePercentage24H: marketCapChangePercentage24H, circulatingSupply: circulatingSupply, totalSupply: totalSupply, maxSupply: maxSupply, ath: ath, athChangePercentage: athChangePercentage, athDate: athDate, atl: atl, atlChangePercentage: atlChangePercentage, atlDate: atlDate, lastUpdated: lastUpdated, price: sparklineIn7D?.price, priceChangePercentage24HInCurrency: priceChangePercentage24HInCurrency, currentHoldings: nil)
    }
}
