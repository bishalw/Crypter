//
//  Core.swift
//  Crypter
//
//  Created by Bishalw on 6/12/24.
//

import Foundation

class Core: ObservableObject {
    
    private lazy var networkingManager: NetworkingManager = {
        return NetworkingManagerImpl()
    }()
    
    private lazy var coinAPIService: CoinAPIService = {
        return CoinAPIServiceImpl(networkingManager: self.networkingManager)
    }()
    
    private lazy var localFileManager: LocalFileManager = {
        return LocalFileManagerImpl()
    }()
    
    private lazy var coinImageRepository: CoinImageRepository = {
        return CoinImageRepositoryImpl(networkingManager: self.networkingManager, localFileManager: self.localFileManager)
    }()
    
    private lazy var globalAPIService: GlobalAPIService = {
        return GlobalAPIServiceImpl(networkingManager: self.networkingManager)
    }()
    
    private lazy var cryptoRepository: CryptoRepository = {
        return CryptoRepositoryImpl(coinAPIService: self.coinAPIService, globalAPIService: self.globalAPIService)
    }()
    
    private lazy var cryptoStore: CryptoStore = {
        return CryptoStoreImpl(repository: self.cryptoRepository)
    }()
    
    // Public accessors for the dependencies
    var getNetworkingManager: NetworkingManager {
        return networkingManager
    }
    
    var getCoinAPIService: CoinAPIService {
        return coinAPIService
    }
    
    var getLocalFileManager: LocalFileManager {
        return localFileManager
    }
    
    var getCoinImageRepository: CoinImageRepository {
        return coinImageRepository
    }
    
    var getGlobalAPIService: GlobalAPIService {
        return globalAPIService
    }
    
    var getCryptoRepository: CryptoRepository {
        return cryptoRepository
    }
    
    var getCryptoStore: CryptoStore {
        return cryptoStore
    }
}
