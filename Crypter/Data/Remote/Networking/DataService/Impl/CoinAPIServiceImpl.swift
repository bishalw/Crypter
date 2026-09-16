//
//  DataService.swift
//  Crypter
//

import Foundation
import Combine

protocol CoinAPIService {
    func fetchAllCoins() -> AnyPublisher<[CoinDTO], Error>
    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailDTO, Error>
    func fetchMarketChart(coinID: String, days: String) -> AnyPublisher<MarketChartDTO, Error>
    func fetchTrendingCoins() -> AnyPublisher<TrendingDTO, Error>
}

class CoinAPIServiceImpl: CoinAPIService {
    
    
    var networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
    }
    
    func fetchAllCoins() -> AnyPublisher<[CoinDTO], Error> {
        guard let coinsURL = CoinAPI.coins.url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }

        return networkingManager.download(url: coinsURL, decodingType: [CoinDTO].self)
    }
    
    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailDTO, Error> {
        guard let coinDetailURL = CoinAPI.coinDetails(coin: coin).url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        return networkingManager.download(url: coinDetailURL, decodingType: CoinDetailDTO.self)
    }
    
    func fetchMarketChart(coinID: String, days: String) -> AnyPublisher<MarketChartDTO, Error> {
        guard let marketChartURL = CoinAPI.marketChart(coinID: coinID, days: days).url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        return networkingManager.download(url: marketChartURL, decodingType: MarketChartDTO.self)
    }

    func fetchTrendingCoins() -> AnyPublisher<TrendingDTO, Error> {
        guard let trendingURL = CoinAPI.trending.url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        return networkingManager.download(url: trendingURL, decodingType: TrendingDTO.self)
    }
}
