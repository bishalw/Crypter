//
//  MockCoinDataservice.swift
//  Crypter
//
//  Created by Bishalw on 12/15/22.
//

import Foundation

class MockCoinDataService: CoinDataService {
    var allCoins: [CoinModel] = []
    
    var networkingManager: MockNetworkingManager
    
    init(networkingManager: MockNetworkingManager) {
        self.networkingManager = networkingManager
    }
    
    func getCoins() {
        
    }
    
}
extension MockCoinDataService{
   
}
