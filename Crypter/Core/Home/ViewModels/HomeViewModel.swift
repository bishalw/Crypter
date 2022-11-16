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
    @Published var sortOption: SortOption = .holdings
    @Published var searchText: String = ""
    
    
    private let coinDataService: CoinDataService // coin data
    private let marketDataService: MarketDataService // global market statistics
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    
    
    enum SortOption {
        case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    }
    
    init(coinDataService: CoinDataService, marketDataService: MarketDataService) {
        self.coinDataService = coinDataService
        self.marketDataService = marketDataService
        addSubscribers()
        }
    
      
    func addSubscribers(){
        
        // filters and searches all the coins from coin data service
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self]( returnedCoins) in
                guard let self = self else { return }
                self.allCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        /*
        1. CombineLatest the two publishers
        2. Map the two publishers to a new value (in this case, an array of updatedCoinModels)
        3. Sink the new value to a subscriber
         */
        $allCoins
            .combineLatest(portfolioDataService.$savedEntites)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] (returnedCoins) in
                self?.portfolioCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        // updates marketData
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobabalMarketData)
            .sink { [weak self] (returnedStats) in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
    }

     
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    private func filterAndSortCoins(text: String, coins: [CoinModel], sort: SortOption ) -> [CoinModel]{
        
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
       
        
    }
    private func filterCoins(text: String, coins:[CoinModel]) -> [CoinModel]{
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
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort {
        case .rank, .holdings:
            coins.sort(by:{ $0.rank < $1.rank })
        case.rankReversed, .holdingsReversed:
            coins.sort(by:{ $0.rank > $1.rank })
        case .price:
            coins.sort(by:{ $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            coins.sort(by:{ $0.currentPrice < $1.currentPrice })
       
        }
    }
    
    private func sortPortfolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel]{
        
        switch sortOption {
        case .holdings:
            return coins.sorted(by: {$0.currentHoldingsValue > $1.currentHoldingsValue})
        case .holdingsReversed:
            return coins.sorted(by: {$0.currentHoldingsValue < $1.currentHoldingsValue})
        default:
            return coins
        }
        
    }
    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
       allCoins
            .compactMap { (coin) -> CoinModel? in
                let foundEntity = portfolioEntities.first { portFolioEntity in
                    portFolioEntity.coinID == coin.id
                }
                
                guard let entity = foundEntity else {
                    return nil
                }
                
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    private func mapGlobabalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel] {
        var stats: [StatisticModel] = []
        guard let data = marketDataModel else {
            return stats
        }
        
        let marketCap = StatisticModel(title: "MarketCap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        let btcDominance = StatisticModel(title: "BTC Dominanace", value: data.btcDominance)
            
        let portfolioValue =
            portfolioCoins
                .map ({ $0.currentHoldingsValue })
                .reduce(0, +)
        
        let portfolio = StatisticModel(title: "Total", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: 0)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance
        ])
        return stats
    }
}
extension HomeViewModel{
    
    var myTotalHoldingDisplayString: String {
        var total = 0.0
        for coin in portfolioCoins {
            total = total + coin.currentHoldingsValue
        }
        return String("\(total.asCurrencyWith2Decimals())")
    }
    
    func reloadData(){
        coinDataService.getCoins()
        marketDataService.getMarketData()
    }
    
}
