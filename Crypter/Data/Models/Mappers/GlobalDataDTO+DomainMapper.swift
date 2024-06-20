//
//  GlobalDataDTO+DomainMapper.swift
//  Crypter
//
//

import Foundation

extension GlobalDataDTO: DomainMapper {
    typealias Domain = MarketDataModel

    func toDomain() -> MarketDataModel {
            guard let data = data else {
                return MarketDataModel(totalMarketCap: [:], totalVolume: [:], marketCapPercentage: [:], marketCapChangePercentage24HUsd: 0.0)
            }
            
            return MarketDataModel(totalMarketCap: data.totalMarketCap,
                                   totalVolume: data.totalVolume,
                                   marketCapPercentage: data.marketCapPercentage,
                                   marketCapChangePercentage24HUsd: data.marketCapChangePercentage24HUsd)
        }
}
