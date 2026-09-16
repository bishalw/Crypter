//
//  Core.swift
//  Crypter
//
//  Created by Bishalw on 6/12/24.
//

import Foundation

class Core: ObservableObject {
    
    private(set) lazy var apiKeyStore: APIKeyStore = {
        return APIKeyStore()
    }()

    private(set) lazy var networkingManager: NetworkingManager = {
        return NetworkingManagerImpl(apiKeyStore: self.apiKeyStore)
    }()
    
    private(set) lazy var coinAPIService: CoinAPIService = {
        return CoinAPIServiceImpl(networkingManager: self.networkingManager)
    }()
    
    private(set) lazy var localFileManager: LocalFileManager = {
        return LocalFileManagerImpl()
    }()
    
    private(set) lazy var coinImageRepository: CoinImageRepository = {
        return CoinImageRepositoryImpl(networkingManager: self.networkingManager, localFileManager: self.localFileManager)
    }()
    
    private(set) lazy var globalAPIService: GlobalAPIService = {
        return GlobalAPIServiceImpl(networkingManager: self.networkingManager)
    }()
    
    private(set) lazy var cryptoRepository: CryptoRepository = {
        return CryptoRepositoryImpl(coinAPIService: self.coinAPIService, globalAPIService: self.globalAPIService)
    }()
    
    private(set) lazy var cryptoStore: CryptoStore = {
        return CryptoStoreImpl(repository: self.cryptoRepository)
    }()

    private(set) lazy var portfolioDataService: PortfolioDataService = {
        return PortfolioDataServiceImpl()
    }()

    private(set) lazy var watchlistStore: WatchlistStore = {
        return WatchlistStore()
    }()
}
