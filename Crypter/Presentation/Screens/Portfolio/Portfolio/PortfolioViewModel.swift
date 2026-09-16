//
//  PortfolioViewModel.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import Foundation
import Combine

protocol PortfolioViewModel: ObservableObject {
    var portfolioCoins: [CoinModel] { get }
    var totalPortfolioValue: Double { get }
    var myTotalHoldingDisplayString: String { get }
    var totalPortfolio24hChange: Double { get }
    var totalPortfolio24hChangePercent: Double { get }
    var sortOption: SortOption { get set }
    var recentTransactions: [PortfolioTransaction] { get }
    var storeErrorMessage: String? { get }
    func removeFromPortfolio(coin: CoinModel)
    func deleteTransaction(id: UUID)
    func updateTransaction(id: UUID, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date)
    func setCostBasis(for coin: CoinModel, pricePerCoin: Double)
    func reloadData()
}

extension PortfolioViewModel {
    // Defaults so lightweight preview VMs can conform without storing these.
    var sortOption: SortOption {
        get { .holdings }
        set { }
    }

    var recentTransactions: [PortfolioTransaction] { [] }

    var storeErrorMessage: String? { nil }

    func deleteTransaction(id: UUID) { }

    func setCostBasis(for coin: CoinModel, pricePerCoin: Double) { }

    func updateTransaction(id: UUID, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date) { }

    /// Coins whose cost basis is known, i.e. everything bought through a transaction.
    private var coinsWithKnownCost: [CoinModel] {
        portfolioCoins.filter { $0.averageCost != nil }
    }

    /// True when some holdings predate transaction tracking, so P/L is partial.
    var hasUnknownCostBasis: Bool {
        portfolioCoins.contains { $0.averageCost == nil }
    }

    var totalCostBasis: Double? {
        let coins = coinsWithKnownCost
        guard !coins.isEmpty else { return nil }
        return coins.compactMap { $0.costBasisValue }.reduce(0, +)
    }

    var allTimeProfit: Double? {
        let coins = coinsWithKnownCost
        guard !coins.isEmpty else { return nil }
        return coins.compactMap { $0.totalProfit }.reduce(0, +)
    }

    var allTimeProfitPercent: Double? {
        guard let totalCostBasis, totalCostBasis > 0, let allTimeProfit else { return nil }
        return (allTimeProfit / totalCostBasis) * 100
    }

    private var realizedProfits: [UUID: Double] {
        PortfolioDataServiceImpl.realizedProfits(from: recentTransactions)
    }

    /// Profit already banked by selling, or nil when nothing has been sold.
    var totalRealizedProfit: Double? {
        let profits = realizedProfits
        guard !profits.isEmpty else { return nil }
        return profits.values.reduce(0, +)
    }

    func realizedProfit(for transaction: PortfolioTransaction) -> Double? {
        realizedProfits[transaction.id]
    }
}

class PortfolioViewModelImpl: PortfolioViewModel {

    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holdings
    @Published var recentTransactions: [PortfolioTransaction] = []
    @Published var storeErrorMessage: String? = nil
    
    private let cryptoStore: CryptoStore
    private let portfolioDataService: PortfolioDataService
    private var cancellables = Set<AnyCancellable>()

    init(cryptoStore: CryptoStore, portfolioDataService:  PortfolioDataService) {
        self.cryptoStore = cryptoStore
        self.portfolioDataService = portfolioDataService
        addSubscribers()
    }
    
    private func addSubscribers() {
        // Combine the latest coins from cryptoStore with saved portfolio entities
        $searchText
            .combineLatest(cryptoStore.coins, portfolioDataService.savedEntitiesPublisher, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map { [weak self] (searchText, allCoins, holdings, sortOption) in
                let portfolioCoins = self?.mapAllCoinsToPortfolioCoins(allCoins: allCoins ?? [], holdings: holdings) ?? []
                return self?.filterAndSortCoins(searchText: searchText, coins: portfolioCoins, sort: sortOption) ?? []
            }
            .sink { [weak self] returnedCoins in
                self?.portfolioCoins = returnedCoins
            }
            .store(in: &cancellables)

        portfolioDataService.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.recentTransactions = transactions
            }
            .store(in: &cancellables)

        portfolioDataService.storeErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.storeErrorMessage = message
            }
            .store(in: &cancellables)
    }

    func deleteTransaction(id: UUID) {
        portfolioDataService.deleteTransaction(id: id)
    }

    func setCostBasis(for coin: CoinModel, pricePerCoin: Double) {
        portfolioDataService.setCostBasis(forCoinID: coin.id, pricePerCoin: pricePerCoin)
    }

    func updateTransaction(id: UUID, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date) {
        portfolioDataService.updateTransaction(id: id, kind: kind, amount: amount, pricePerCoin: pricePerCoin, date: date)
    }

    func removeFromPortfolio(coin: CoinModel) {
        portfolioDataService.deleteAllTransactions(forCoinID: coin.id)
    }
    
    func reloadData() {
        cryptoStore.fetchAllCoins()
    }
    
    private func filterAndSortCoins(searchText: String, coins: [CoinModel], sort: SortOption) -> [CoinModel] {
        var updatedCoins = filterCoins(text: searchText, coins: coins)
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else { return coins }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { coin in
            coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    private func sortCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort {
        case .holdings:
            coins.sort(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
        case .holdingsReversed:
            coins.sort(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
        case .rank:
            coins.sort(by: { $0.rank < $1.rank })
        case .rankReversed:
            coins.sort(by: { $0.rank > $1.rank })
        case .price:
            coins.sort(by: { $0.currentPrice > $1.currentPrice })
        case .priceReversed:
            coins.sort(by: { $0.currentPrice < $1.currentPrice })
        case .gainers:
            coins.sort(by: { ($0.priceChangePercentage24H ?? 0) > ($1.priceChangePercentage24H ?? 0) })
        case .losers:
            coins.sort(by: { ($0.priceChangePercentage24H ?? 0) < ($1.priceChangePercentage24H ?? 0) })
        }
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

extension PortfolioViewModelImpl {
    var totalPortfolioValue: Double {
        portfolioCoins.map { $0.currentHoldingsValue }.reduce(0, +)
    }

    var myTotalHoldingDisplayString: String {
        "$\(totalPortfolioValue.formattedWithAbbreviations())"
    }

    var totalPortfolio24hChange: Double {
        portfolioCoins.reduce(0) { result, coin in
            result + (coin.priceChange24H ?? 0) * (coin.currentHoldings ?? 0)
        }
    }

    var totalPortfolio24hChangePercent: Double {
        let previousValue = totalPortfolioValue - totalPortfolio24hChange
        guard previousValue > 0 else { return 0 }
        return (totalPortfolio24hChange / previousValue) * 100
    }
}
