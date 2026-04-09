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
    func updatePortfolio(coin: CoinModel, amount: Double)
    func reloadData()
}

extension PortfolioViewModel {
    // Default so lightweight preview VMs can conform without storing this.
    var sortOption: SortOption {
        get { .holdings }
        set { }
    }
}

class PortfolioViewModelImpl: PortfolioViewModel {

    @Published var portfolioCoins: [CoinModel] = []
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .holdings
    
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
            .map { [weak self] (searchText, allCoins, portfolioEntities, sortOption) in
                let portfolioCoins = self?.mapAllCoinsToPortfolioCoins(allCoins: allCoins ?? [], portfolioEntities: portfolioEntities) ?? []
                return self?.filterAndSortCoins(searchText: searchText, coins: portfolioCoins, sort: sortOption) ?? []
            }
            .sink { [weak self] returnedCoins in
                self?.portfolioCoins = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
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
        }
    }
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
        allCoins.compactMap { coin -> CoinModel? in
            guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                return nil
            }
            return coin.updateHoldings(amount: entity.amount)
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
