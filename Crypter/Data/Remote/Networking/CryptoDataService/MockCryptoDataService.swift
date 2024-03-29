//
//  MockCryptoDataService.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

class MockCryptoDataService: CryptoDataService {
    
    var image: CurrentValueSubject<UIImage?,Never> = CurrentValueSubject(nil)
    var marketData: CurrentValueSubject<MarketDataModel?, Never> = CurrentValueSubject(nil)
    var allCoins: CurrentValueSubject<[CoinModel], Never> = CurrentValueSubject([])
    var coinDetails: CurrentValueSubject<CoinDetailModel?, Never> = CurrentValueSubject(nil)

    func getMarketData() {
        // Sending new value to marketData
        self.marketData.send(MarketDataModel.mockMarketDataModel())
    }
    
    func getCoins() {
        // Sending new value to allCoins
        self.allCoins.send(CoinModel.mockCoins())
    }
    
    func getCoinDetails(coin: CoinModel) {
        // Sending new value to coinDetails
        self.coinDetails.send(CoinDetailModel.mockCoinDetails(for: coin))
    }
}
