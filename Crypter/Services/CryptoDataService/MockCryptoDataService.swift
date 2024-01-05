//
//  MockCryptoDataService.swift
//  Crypter
//
//  Created by Bishalw on 1/4/24.
//

import Foundation


class MockCryptoDataService: CryptoDataService {
    
    var marketDataPublisher: Published<MarketDataModel?>.Publisher { $marketData }
    var allCoinsPublisher: Published<[CoinModel]>.Publisher { $allCoins }
    var coinDetailsPublisher: Published<CoinDetailModel?>.Publisher { $coinDetails }
    
    @Published var marketData: MarketDataModel?
    @Published var allCoins: [CoinModel] = []
    @Published var coinDetails: CoinDetailModel?
    
    func getMarketData() {
        self.marketData = MarketDataModel.mockMarketDataModel()
    }
    
    func getCoins() {
        self.allCoins = CoinModel.mockCoins()
    }
    
    func getCoinDetails(coin: CoinModel) {
        self.coinDetails = CoinDetailModel.mockCoinDetails(for: coin)
    }
    
}
