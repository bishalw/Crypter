//
//  DetailViewModel.swift
//  Crypter
//
//

import Foundation
import Combine

protocol DetailViewModel: ObservableObject{
    var overViewStatistics: [StatisticModel] { get set }
    var additionalStatistics: [StatisticModel] { get set }
    var coin: CoinModel { get set }
    var coinDescription: String? { get set }
    var websiteURL: String? { get set }
    var redditURL: String? { get set }
}

class DetailViewModelImpl: ObservableObject, DetailViewModel{
  
    @Published var overViewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    @Published var coin: CoinModel
    private let cryptoStore: CryptoStore
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, cryptoStore: CryptoStore) {
        self.coin = coin
        self.cryptoStore = cryptoStore
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        cryptoStore.coinDetails
            .sink { [weak self] (returnedCoinDetails) in
                self?.updateDetails(returnedCoinDetails: returnedCoinDetails)
            }
            .store(in: &cancellables)
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
        //OverViewArray
        let overviewArray = createOverViewArray(coinModel: coinModel)
        //Additional Arra
        let additionalArray = createAdditionalArray(coinModel: coinModel, coinDetailModel: coinDetailModel)
        
        return(overviewArray,additionalArray)
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
