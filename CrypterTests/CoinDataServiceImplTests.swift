//
//  CoinDataServiceImplTests.swift
//  CrypterTests
//
//  Created by Bishalw on 12/16/22.
//

import Foundation
import XCTest
@testable import Crypter

class CoinDataServiceImplTests: XCTestCase {
    
    func test_getCoins_call_networkManagerWithRightURL() {
        let mockNetorkingManager = MockNetworkingManager()
        let subject = CoinDataServiceImpl(networkingManager: mockNetorkingManager)
        subject.getCoins()
        let didCallDownloadOnNetworkManager = mockNetorkingManager.lastestDownloadCall != nil
        
        let urlUsedForDownalod: URL = mockNetorkingManager.lastestDownloadCall!
        
        let expectedURL = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        
        XCTAssert(didCallDownloadOnNetworkManager)
        XCTAssert(urlUsedForDownalod == expectedURL)
    }
    
    
    override func setUp() async throws {
        
    }
    
    override class func tearDown() {
        
    }
}
