//
//  DataService.swift
//  Crypter
//

import Foundation
import Combine

protocol CoinAPIService {
    func fetchAllCoins() -> AnyPublisher<[CoinDTO], Error>
    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailDTO, Error>
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
    
}
