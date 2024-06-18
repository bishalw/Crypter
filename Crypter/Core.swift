//
//  Core.swift
//  Crypter
//
//  Created by Bishalw on 6/12/24.
//

import Foundation

class Core: ObservableObject {
    
    private lazy var _networkingManager: NetworkingManagerImpl = {
           return NetworkingManagerImpl()
       }()
       
       var networkingManager: NetworkingManagerImpl {
           return _networkingManager
       }
       
       private lazy var _coinAPIService: CoinAPIServiceImpl = {
           return CoinAPIServiceImpl(networkingManager: self.networkingManager)
       }()
       
       var coinAPIService: CoinAPIServiceImpl {
           return _coinAPIService
       }
       
       private lazy var _globalAPIService: GlobalAPIServiceImpl = {
           return GlobalAPIServiceImpl(networkingManager: self.networkingManager)
       }()
       
       var globalAPIService: GlobalAPIServiceImpl {
           return _globalAPIService
       }
    private lazy var _cryptoRepository: CryptoRepositoryImpl = {
        return CryptoRepositoryImpl(coinAPIService: self.coinAPIService, globalAPIService: self.globalAPIService)
    }()
    
    var cryptoRepository: CryptoRepositoryImpl {
        return _cryptoRepository
    }
    
    private lazy var _cryptoStore: CryptoStore = {
        return CryptoStore(repository: self.cryptoRepository)
    }()
    
    var cryptoStore: CryptoStore {
        return _cryptoStore
    }
    
}
