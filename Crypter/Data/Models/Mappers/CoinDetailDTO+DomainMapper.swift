//
//  CoinDetailDTO+DomainMapper.swift
//  Crypter
//
//

import Foundation
extension CoinDetailDTO: DomainMapper {
    
    func toDomain() -> CoinDetailModel {
        return CoinDetailModel(id: id, symbol: symbol, name: name, blockTimeInMinutes: blockTimeInMinutes, hashingAlgorithm: hashingAlgorithm, description: description, links: links?.toDomain())
    }
}

