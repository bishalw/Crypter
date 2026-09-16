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
    func fetchMarketChart(coinID: String, days: String) -> AnyPublisher<[ChartPoint], Error>
    func fetchTrendingCoins() -> AnyPublisher<[TrendingCoinModel], Error>
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

    func fetchMarketChart(coinID: String, days: String) -> AnyPublisher<[ChartPoint], Error> {
        return coinAPIService.fetchMarketChart(coinID: coinID, days: days)
            .map { dto in
                dto.prices.compactMap { priceEntry in
                    guard priceEntry.count == 2 else { return nil }
                    return ChartPoint(
                        date: Date(timeIntervalSince1970: priceEntry[0] / 1000),
                        price: priceEntry[1]
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchTrendingCoins() -> AnyPublisher<[TrendingCoinModel], Error> {
        return coinAPIService.fetchTrendingCoins()
            .map { trendingDTO in
                trendingDTO.toDomain()
            }
            .eraseToAnyPublisher()
    }
}

    
