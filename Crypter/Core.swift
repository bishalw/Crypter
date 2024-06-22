//
//  Core.swift
//  Crypter
//
//  Created by Bishalw on 6/12/24.
//

import Foundation

class Core: ObservableObject {
    
    private lazy var networkingManager: NetworkingManagerImpl = {
        return NetworkingManagerImpl()
    }()
    
    private lazy var coinAPIService: CoinAPIServiceImpl = {
        return CoinAPIServiceImpl(networkingManager: self.networkingManager)
    }()
    
    private lazy var localFileManager: LocalFileManagerImpl = {
        return LocalFileManagerImpl()
    }()
    
    private lazy var coinImageRepository: CoinImageRepositoryImpl = {
        return CoinImageRepositoryImpl(networkingManager: self.networkingManager, localFileManager: self.localFileManager)
    }()
    
    private lazy var globalAPIService: GlobalAPIServiceImpl = {
        return GlobalAPIServiceImpl(networkingManager: self.networkingManager)
    }()
    
    private lazy var cryptoRepository: CryptoRepositoryImpl = {
        return CryptoRepositoryImpl(coinAPIService: self.coinAPIService, globalAPIService: self.globalAPIService)
    }()
    
    private lazy var cryptoStore: CryptoStoreImpl = {
        return CryptoStoreImpl(repository: self.cryptoRepository)
    }()
    
    // Public accessors for the dependencies
    var getNetworkingManager: NetworkingManagerImpl {
        return networkingManager
    }
    
    var getCoinAPIService: CoinAPIServiceImpl {
        return coinAPIService
    }
    
    var getLocalFileManager: LocalFileManagerImpl {
        return localFileManager
    }
    
    var getCoinImageRepository: CoinImageRepositoryImpl {
        return coinImageRepository
    }
    
    var getGlobalAPIService: GlobalAPIServiceImpl {
        return globalAPIService
    }
    
    var getCryptoRepository: CryptoRepositoryImpl {
        return cryptoRepository
    }
    
    var getCryptoStore: CryptoStoreImpl {
        return cryptoStore
    }
}
