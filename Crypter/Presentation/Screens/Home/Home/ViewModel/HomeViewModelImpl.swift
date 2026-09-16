//
//  HomeViewModel.swift
//  Crypter
//

//

import Foundation
import Combine


protocol HomeViewModel: ObservableObject {
    var statistics: [StatisticModel] { get }
    var allCoins: [CoinModel] { get  }
    var portfolioCoins: [CoinModel] { get }
    var trendingCoins: [TrendingCoinModel] { get }
    var searchText: String { get set  }
    var sortOption: SortOption { get set  }
    var myTotalHoldingDisplayString: String { get }
    var errorMessage: String? { get }
    var isLoading: Bool { get }
    var isSearching: Bool { get }
    func addTransaction(coin: CoinModel, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date)
    func reloadData()
}

class HomeViewModelImpl: HomeViewModel {
    
    @Published var statistics: [StatisticModel] = []
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    @Published var trendingCoins: [TrendingCoinModel] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isSearching: Bool = false
    @Published private var searchResults: [CoinModel] = []
    @Published var sortOption: SortOption = .rank
    @Published var searchText: String = ""
    
    private let portfolioDataService: PortfolioDataService
    private let cryptoStore: CryptoStore
    private var cancellables = Set<AnyCancellable>()

    
    init(cryptoStore: CryptoStore, portfolioDataService: PortfolioDataService) {
        self.cryptoStore = cryptoStore
        self.portfolioDataService = portfolioDataService
        cryptoStore.fetchAllCoins()
        cryptoStore.fetchGlobalData()
        cryptoStore.fetchTrendingCoins()
        addSubscribers()
    }

    private func addSubscribers(){
        // filters and searches all the coins from coin data service
        $searchText
                  .combineLatest(cryptoStore.coins, $sortOption, $searchResults)
                  .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
                  .map { [weak self] text, coins, sort, remoteMatches in
                      self?.filterAndSortCoins(
                          text: text,
                          coins: coins,
                          sort: sort,
                          remoteMatches: remoteMatches
                      ) ?? []
                  }
                  .sink { [weak self] returnedCoins in
                      self?.allCoins = returnedCoins
                  }
                  .store(in: &cancellables)
    
        /*
        1. CombineLatest the two publishers
        2. Map the two publishers to a new value (in this case, an array of updatedCoinModels)
        3. Sink the new value to a subscriber
         */
        cryptoStore.globalDetails
            .sink { [weak self] marketDataModel in
                guard let self = self else { return }
                self.statistics = self.mapGlobalMarketData(marketDataModel: marketDataModel)
            }
            .store(in: &cancellables)

        cryptoStore.coins
            .combineLatest(portfolioDataService.savedEntitiesPublisher)
            .map { [weak self] allCoins, holdings in
                self?.mapAllCoinsToPortfolioCoins(allCoins: allCoins ?? [], holdings: holdings) ?? []
            }
            .sink { [weak self] returnedCoins in
                self?.portfolioCoins = returnedCoins
            }
            .store(in: &cancellables)

        cryptoStore.trendingCoins
            .sink { [weak self] returnedCoins in
                self?.trendingCoins = returnedCoins
            }
            .store(in: &cancellables)

        cryptoStore.marketErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorMessage = message
            }
            .store(in: &cancellables)

        cryptoStore.isLoadingMarkets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        cryptoStore.searchResults
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                self?.searchResults = coins
            }
            .store(in: &cancellables)

        cryptoStore.isSearching
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSearching in
                self?.isSearching = isSearching
            }
            .store(in: &cancellables)

        // The loaded page answers instantly; the remote search covers the rest
        // of the listed coins and arrives a moment later.
        $searchText
            .debounce(for: .seconds(0.35), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.cryptoStore.searchCoins(query: text)
            }
            .store(in: &cancellables)
        
    }

    func reloadData(){
        cryptoStore.fetchAllCoins()
        cryptoStore.fetchGlobalData()
        cryptoStore.fetchTrendingCoins()
    }
    func addTransaction(coin: CoinModel, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date) {
        portfolioDataService.addTransaction(coin: coin, kind: kind, amount: amount, pricePerCoin: pricePerCoin, date: date)
    }
    
    private func filterAndSortCoins(
        text: String,
        coins: [CoinModel]?,
        sort: SortOption,
        remoteMatches: [CoinModel]
    ) -> [CoinModel] {
        guard let coins = coins else { return [] }

        var updatedCoins = filterCoins(text: text, coins: coins)

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            sortCoins(sort: sort, coins: &updatedCoins)
            return updatedCoins
        }

        // Local matches first — they are the highest-ranked coins and are
        // already on screen — then anything the remote search turned up.
        let localIDs = Set(updatedCoins.map { $0.id })
        return updatedCoins + remoteMatches.filter { !localIDs.contains($0.id) }
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
        case .gainers:
            coins.sort(by: { ($0.priceChangePercentage24H ?? 0) > ($1.priceChangePercentage24H ?? 0) })
        case .losers:
            coins.sort(by: { ($0.priceChangePercentage24H ?? 0) < ($1.priceChangePercentage24H ?? 0) })
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
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?) -> [StatisticModel] {
        guard let data = marketDataModel else {
            return []
        }
        return data.asHomeStatistics()
    }

    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], holdings: [PortfolioHolding]) -> [CoinModel] {
        allCoins.compactMap { coin -> CoinModel? in
            guard let holding = holdings.first(where: { $0.coinID == coin.id }) else {
                return nil
            }

            return coin.updatePosition(amount: holding.amount, averageCost: holding.averageCost)
        }
    }
    
}
extension HomeViewModelImpl {
    var myTotalHoldingDisplayString: String {
        var total = 0.0
        for coin in portfolioCoins {
            total = total + coin.currentHoldingsValue
        }
        return String("$\(total.formattedWithAbbreviations())")
    }
}



enum SortOption {
    case rank, rankReversed, holdings, holdingsReversed, price, priceReversed
    case gainers, losers
}
