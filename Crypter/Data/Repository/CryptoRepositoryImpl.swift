//
//  CryptoRepositoryImpl.swift
//  Crypter
//
//

import Foundation
import Combine

protocol CryptoRepository {
    func fetchAllCoins() -> AnyPublisher<[CoinModel], Error>
    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailModel, Error>
    func fetchGlobalData() -> AnyPublisher<MarketDataModel, Error>

}
class CryptoRepositoryImpl: CryptoRepository{
    
    private let globalAPIService: GlobalAPIService
    private let coinAPIService: CoinAPIService
    
    
    init(coinAPIService: CoinAPIService, globalAPIService: GlobalAPIService) {
        self.globalAPIService = globalAPIService
        self.coinAPIService = coinAPIService
    }

    func fetchAllCoins() -> AnyPublisher<[CoinModel], Error> {
        return coinAPIService.fetchAllCoins()
            .map { coinDTOs in
                coinDTOs.map { $0.toDomain() }
            }
            .eraseToAnyPublisher()
    }

    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailModel, Error> {
        return coinAPIService.fetchCoinDetail(coin: coin)
            .map{ coinDetailDTO in
                coinDetailDTO.toDomain() }
            .eraseToAnyPublisher()
    }
    
    func fetchGlobalData() -> AnyPublisher<MarketDataModel, Error> {
        return globalAPIService.fetchGlobalData()
            .map { globalDataDTO in
                globalDataDTO.toDomain()
            }
            .eraseToAnyPublisher()
    }
    
}

    
