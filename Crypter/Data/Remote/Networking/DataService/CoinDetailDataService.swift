//
//  CoinDetailDataService.swift
//  Crypter
//
//  Created by Bishalw on 1/12/24.
//

import Foundation
import Combine

protocol CoinDetailDataService  {
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> { get }
}

class CoinDetailDataServiceImpl: CoinDetailDataService {
    //MARK: Public
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> = CurrentValueSubject<CoinDetailModel?,Never>(nil)
    
    var networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
    }
    
    func fetchCoinDetail(coin: CoinModel) -> AnyPublisher<CoinDetailModel, Error> {
        guard let marketDataURL = CoinAPI.coinDetails(coin: coin).url else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        return networkingManager.download(url: marketDataURL, decodingType: CoinDetailModel.self)
    }
}
