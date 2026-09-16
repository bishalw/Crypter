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
    func searchCoins(query: String) -> AnyPublisher<[CoinModel], Error>
}

class CryptoRepositoryImpl: CryptoRepository{
    
    private let globalAPIService: GlobalAPIService
    private let coinAPIService: CoinAPIService
    
    
    init(coinAPIService: CoinAPIService, globalAPIService: GlobalAPIService) {
        self.globalAPIService = globalAPIService
        self.coinAPIService = coinAPIService
    }

    /// Searches every listed coin, then prices the best matches. Two calls,
    /// because /search returns no market data.
    func searchCoins(query: String) -> AnyPublisher<[CoinModel], Error> {
        return coinAPIService.searchCoins(query: query)
            .map { $0.rankedIDs(limit: 25) }
            .flatMap { [weak self] ids -> AnyPublisher<[CoinModel], Error> in
                guard let self, !ids.isEmpty else {
                    return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                }

                return self.coinAPIService.fetchCoins(ids: ids)
                    .map { dtos in
                        let coins = dtos.map { $0.toDomain() }
                        // /coins/markets ignores the order of the ids, so restore it.
                        return ids.compactMap { id in coins.first(where: { $0.id == id }) }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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

    
