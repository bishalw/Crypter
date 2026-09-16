//
//  DetailViewModel.swift
//  Crypter
//

import Foundation
import Combine

protocol DetailViewModel: ObservableObject {
    var overViewStatistics: [StatisticModel] { get set }
    var additionalStatistics: [StatisticModel] { get set }
    var coin: CoinModel { get set }
    var coinDescription: String? { get set }
    var websiteURL: String? { get set }
    var redditURL: String? { get set }
    var chartPoints: [ChartPoint] { get set }
    var isLoadingChart: Bool { get set }
    var chartErrorMessage: String? { get set }
    var transactions: [PortfolioTransaction] { get }
    var holding: PortfolioHolding? { get }

    func fetchMarketChart(range: ChartTimeRange)
    func realizedProfit(for transaction: PortfolioTransaction) -> Double?
}

class DetailViewModelImpl: ObservableObject, DetailViewModel {
  
    @Published var overViewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    @Published var chartPoints: [ChartPoint] = []
    @Published var isLoadingChart: Bool = false
    @Published var chartErrorMessage: String? = nil
    @Published var transactions: [PortfolioTransaction] = []
    @Published var holding: PortfolioHolding? = nil
    
    @Published var coin: CoinModel
    private let cryptoStore: CryptoStore
    private let portfolioDataService: PortfolioDataService?
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, cryptoStore: CryptoStore, portfolioDataService: PortfolioDataService? = nil) {
        self.coin = coin
        self.cryptoStore = cryptoStore
        self.portfolioDataService = portfolioDataService
        self.addSubscribers()
        
        // Initial fetches
        cryptoStore.fetchCoinDetails(coin: coin)
        fetchMarketChart(range: .week)
    }
    
    func realizedProfit(for transaction: PortfolioTransaction) -> Double? {
        PortfolioDataServiceImpl.realizedProfits(from: transactions)[transaction.id]
    }

    func fetchMarketChart(range: ChartTimeRange) {
        isLoadingChart = true
        chartErrorMessage = nil
        cryptoStore.fetchMarketChart(coin: coin, range: range)
    }
    
    private func addSubscribers() {
        portfolioDataService?.transactionsPublisher
            .map { [weak self] transactions in
                transactions.filter { $0.coinID == self?.coin.id }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.transactions = transactions
            }
            .store(in: &cancellables)

        portfolioDataService?.savedEntitiesPublisher
            .map { [weak self] holdings in
                holdings.first(where: { $0.coinID == self?.coin.id })
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] holding in
                self?.holding = holding

                guard let self, let holding else { return }
                self.coin = self.coin.updatePosition(amount: holding.amount, averageCost: holding.averageCost)
            }
            .store(in: &cancellables)

        cryptoStore.coinDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (returnedCoinDetails) in
                self?.updateDetails(returnedCoinDetails: returnedCoinDetails)
            }
            .store(in: &cancellables)
            
        cryptoStore.chartPoints
            .receive(on: DispatchQueue.main)
            .sink { [weak self] returnedPoints in
                self?.chartPoints = returnedPoints
                self?.isLoadingChart = false
            }
            .store(in: &cancellables)

        cryptoStore.chartErrorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self = self else { return }
                self.chartErrorMessage = message
                if message != nil {
                    self.isLoadingChart = false
                }
            }
            .store(in: &cancellables)
            
        // Setup initial overview
        let statisticsData = mapDataToStatistics(coinDetailModel: nil, coinModel: coin)
        overViewStatistics = statisticsData.overview
        additionalStatistics = statisticsData.additional
    }
    
    private func updateDetails(returnedCoinDetails: CoinDetailModel?) {
        coinDescription = returnedCoinDetails?.readableDescription
        websiteURL = returnedCoinDetails?.links?.homepage?.first
        redditURL = returnedCoinDetails?.links?.subredditURL
        
        let statisticsData = mapDataToStatistics(coinDetailModel: returnedCoinDetails, coinModel: coin)
        overViewStatistics = statisticsData.overview
        additionalStatistics = statisticsData.additional
    }
        
    private func mapDataToStatistics(coinDetailModel: CoinDetailModel?, coinModel: CoinModel) -> (overview: [StatisticModel], additional:[StatisticModel]) {
        let overviewArray = createOverViewArray(coinModel: coinModel)
        let additionalArray = createAdditionalArray(coinModel: coinModel, coinDetailModel: coinDetailModel)
        return (overviewArray, additionalArray)
    }
    
    private func createOverViewArray(coinModel: CoinModel) -> [StatisticModel] {
        let statistics = [
            ("Current Price", coinModel.currentPrice.asCurrencyWith6Decimals(), coinModel.priceChangePercentage24H),
            ("Market Capitalization", formatCurrency(coinModel.marketCap), coinModel.marketCapChangePercentage24H),
            ("Rank", "\(coinModel.rank)", nil),
            ("Volume", formatCurrency(coinModel.totalVolume), nil)
        ]
        
        return statistics.map { title, value, percentageChange in
            StatisticModel(title: title, value: value, percentageChange: percentageChange)
        }
    }

    private func formatCurrency(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return "$" + value.formattedWithAbbreviations()
    }
    
    private func createAdditionalArray(coinModel: CoinModel, coinDetailModel: CoinDetailModel?) -> [StatisticModel] {
        return [
            StatisticModel(title: "24h High", value: coinModel.high24H?.asCurrencyWith6Decimals() ?? "N/A"),
            StatisticModel(title: "24h Low", value: coinModel.low24H?.asCurrencyWith6Decimals() ?? "N/A"),
            StatisticModel(
                title: "24h Price Change",
                value: "$\(coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "N/A")",
                percentageChange: coinModel.priceChangePercentage24H
            ),
            StatisticModel(
                title: "24h Market Cap Change",
                value: coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "0",
                percentageChange: coinModel.marketCapChangePercentage24H
            ),
            StatisticModel(title: "Block Time", value: "\(coinDetailModel?.blockTimeInMinutes ?? 0)"),
            StatisticModel(title: "Hashing Algorithm", value: coinDetailModel?.hashingAlgorithm ?? "N/A")
        ]
    }
}
