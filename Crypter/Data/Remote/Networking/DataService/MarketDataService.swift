//
//  MarketDataService.swift
//  Crypter
//
//  Created by Bishalw on 1/12/24.
//

import Foundation
import Combine

protocol MarketDataService  {
    var marketData: CurrentValueSubject<MarketDataModel?,Never> { get }
}

class MarketDataServiceImpl: MarketDataService {
    
    var marketData: CurrentValueSubject<MarketDataModel?,Never> = CurrentValueSubject<MarketDataModel?,Never>(nil)
    
    var networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
    }
    
    func fetchMarketData() -> AnyPublisher<GlobalData, Error> {
        guard let marketDataURL = CoinAPI.marketData.url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        return networkingManager.download(url: marketDataURL, decodingType: GlobalData.self)
    }
}
