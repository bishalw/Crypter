//
//  CryptoDataService.swift
//  Crypter
//
//

import Foundation
import Combine

protocol CryptoDataService {
    func getCoinDetails(coin: CoinModel)
    var marketData: CurrentValueSubject<MarketDataModel?,Never> { get }
    var allCoins: CurrentValueSubject<[CoinModel], Never> { get }
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> { get }
    func getMarketData()
    func getCoins()
}

class CryptoDataServiceImpl: CryptoDataService {
    
    // Publishers
    var marketData: CurrentValueSubject<MarketDataModel?,Never> = CurrentValueSubject<MarketDataModel?,Never>(nil)
    var allCoins: CurrentValueSubject<[CoinModel], Never> = CurrentValueSubject<[CoinModel], Never>([])
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> = CurrentValueSubject<CoinDetailModel?,Never>(nil)
    // Subscriptions
    var marketDataSubscription: AnyCancellable?
    var coinSubscription: AnyCancellable?
    var coinDetailSubscription: AnyCancellable?
    
    var networkingManager: NetworkingManager
    
    // Initialize with a NetworkingManager and fetch data
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
        getMarketData()
        getCoins()
    }
    
    func getMarketData() {
        let marketDataURL = URL(string: "https://api.coingecko.com/api/v3/global")
        guard let url = marketDataURL else { return }
        
        marketDataSubscription = networkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedGlobalData) in
                self?.marketData.send(returnedGlobalData.data)
                self?.marketDataSubscription?.cancel()
            })
    }
    
    func getCoins() {
        let coinsURL = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        guard let url = coinsURL else { return }
        
        coinSubscription = networkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoins) in
                self?.allCoins.send(returnedCoins)
                self?.coinSubscription?.cancel()
            })
    }
    
    func getCoinDetails(coin: CoinModel) {
        let optionalUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        guard let url = optionalUrl else { return }
        
        coinDetailSubscription = networkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoinDetails) in
                self?.coinDetails.send(returnedCoinDetails)
                self?.coinDetailSubscription?.cancel()
            })
    }
    
    private func handleCompletion(status: Subscribers.Completion<Error>) {
        switch status {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

