//
//  TrendingDTO+DomainMapper.swift
//  Crypter
//

import Foundation

extension TrendingDTO: DomainMapper {
    typealias ModelType = [TrendingCoinModel]

    func toDomain() -> [TrendingCoinModel] {
        coins.map { wrapper in
            TrendingCoinModel(
                id: wrapper.item.id,
                name: wrapper.item.name,
                symbol: wrapper.item.symbol,
                imageURL: wrapper.item.small,
                priceChangePercentage24H: wrapper.item.data?.priceChangePercentage24H?.usd
            )
        }
    }
}
