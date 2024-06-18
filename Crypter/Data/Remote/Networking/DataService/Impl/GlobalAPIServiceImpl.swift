//
//  MarketDataService.swift
//  Crypter
//
//

import Foundation
import Combine

protocol GlobalAPIService  {
    func fetchGlobalData() -> AnyPublisher<GlobalDataDTO,Error>
}

class GlobalAPIServiceImpl: GlobalAPIService {
    
    var networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
    }
    
    func fetchGlobalData() -> AnyPublisher<GlobalDataDTO,Error> {
        guard let globalDataURL = CoinAPI.globalData.url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        return networkingManager.download(url: globalDataURL, decodingType: GlobalDataDTO.self)
    }
}
