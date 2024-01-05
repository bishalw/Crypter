//
//  CryptoDataService.swift
//  Crypter
//
//

import Foundation
import Combine

protocol CryptoDataService {
    var marketDataPublisher: Published<MarketDataModel?>.Publisher { get }
    var allCoinsPublisher: Published<[CoinModel]>.Publisher { get }
    var coinDetailsPublisher: Published<CoinDetailModel?>.Publisher { get }
    func getMarketData()
    func getCoins()
    func getCoinDetails(coin: CoinModel)
}

class CryptoDataServiceImpl: ObservableObject {
    
    // Published properties for subscribers
    @Published var marketData: MarketDataModel? = nil
    @Published var allCoins: [CoinModel] = []
    @Published var coinDetails: CoinDetailModel? = nil
    
    
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
                self?.marketData = returnedGlobalData.data
                self?.marketDataSubscription?.cancel()
            })
    }
    
    func getCoins() {
        let coinsURL = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        guard let url = coinsURL else { return }
        
        coinSubscription = networkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoins) in
                self?.allCoins = returnedCoins
                self?.coinSubscription?.cancel()
            })
    }
    
    func getCoinDetails(coin: CoinModel) {
            let optionalUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
            guard let url = optionalUrl else { return }

            coinDetailSubscription = networkingManager.download(url: url)
                .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
                .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoinDetails) in
                    self?.coinDetails = returnedCoinDetails
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
extension CryptoDataServiceImpl: CryptoDataService {
    
    var marketDataPublisher: Published<MarketDataModel?>.Publisher { $marketData }
    var allCoinsPublisher: Published<[CoinModel]>.Publisher { $allCoins }
    var coinDetailsPublisher: Published<CoinDetailModel?>.Publisher { $coinDetails }

}
