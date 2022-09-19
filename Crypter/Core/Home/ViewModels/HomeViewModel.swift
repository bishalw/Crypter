//
//  HomeViewModel.swift
//  Crypter
//

//

import Foundation
import Combine


class HomeViewModel: ObservableObject {
    
    @Published var statistics: [StatisticModel] = []
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    @Published var searchText: String = ""
    
    private let coinDataService: CoinDataService
    private let marketDataService: MarketDataService
    private var cancellables = Set<AnyCancellable>()
    // get data from allCoins in coinData service to HomeviewModel allCoins
    
    init(coinDataService: CoinDataService, marketDataService: MarketDataService) {
        self.coinDataService = coinDataService
        self.marketDataService = marketDataService
        addSubscribers()
        }
    
    
    func addSubscribers(){
        
        $searchText // filters and searches all the coins from coin data service
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // waits 0.5 seconds for another published value
            .map(filterCoins)
            .sink { [weak self]( returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        marketDataService.$marketData
            .map{(MarketDataModel) -> [StatisticModel] in
                
                var stats: [StatisticModel] = []
                guard let data = MarketDataModel else {
                    return stats
                }
                
                let marketCap = StatisticModel(title: "MarketCap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
                let volume = StatisticModel(title: "24h Volume", value: data.volume)
                let btcDominance = StatisticModel(title: "BTC Dominanace", value: data.btcDominance)
                let portfolio = StatisticModel(title: "Portfolo Value", value: "$0.00", percentageChange: 0)
                
                
                stats.append(contentsOf: [
                    marketCap,
                    volume,
                    btcDominance
                ])
                return stats
            }
            .sink { [weak self] (returnedStats) in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
                coin.symbol.lowercased().contains(lowercasedText) ||
                coin.id.lowercased().contains(lowercasedText)
        }
    }
}
