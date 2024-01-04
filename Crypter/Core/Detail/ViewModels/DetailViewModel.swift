//
//  DetailViewModel.swift
//  Crypter
//
//  Created by Bishalw on 11/16/22.
//

import Foundation
import Combine
class DetailViewModel: ObservableObject{
  
    @Published var overViewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    @Published var coinDescription: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    @Published var coin: CoinModel
    private let cryptoDataService: CryptoDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, cryptoDataService: CryptoDataService) {
        self.coin = coin
        self.cryptoDataService = cryptoDataService
        self.addSubscribers()
    }
    
    private func addSubscribers(){
        cryptoDataService.coinDetailsPublisher
            .combineLatest($coin)
            .map(mapDataToStatistics)
            .sink { [weak self] (returnedArrays) in
                guard let strongSelf = self else { return }
                strongSelf.overViewStatistics = returnedArrays.overview
                strongSelf.additionalStatistics = returnedArrays.additional
            }
            .store(in: &cancellables)
        
        cryptoDataService.coinDetailsPublisher
            .sink { [weak self] (returnedCoinDetails) in
                guard let strongSelf = self else { return }
                strongSelf.coinDescription = returnedCoinDetails?.readableDescription
                strongSelf.websiteURL = returnedCoinDetails?.links?.homepage?.first
                strongSelf.redditURL = returnedCoinDetails?.links?.subredditURL
            }
            .store(in: &cancellables)
        
    }
    private func mapDataToStatistics(coinDetailModel: CoinDetailModel?, coinModel: CoinModel) -> (overview: [StatisticModel], additional:[StatisticModel]) {
        //OverViewArray
        let overviewArray = createOverViewArray(coinModel: coinModel)
        //Additional Arra
        let additionalArray = createAdditionalArray(coinModel: coinModel, coinDetailModel: coinDetailModel)
        
        return(overviewArray,additionalArray)
    }
    
    func createOverViewArray(coinModel: CoinModel) -> [StatisticModel] {
        
        let price = coinModel.currentPrice.asCurrencyWith6Decimals()
        let priceChange = coinModel.priceChangePercentage24H
        let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: priceChange)
        //row 1, col 2
        let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
        let marketCapChange = coinModel.marketCapChangePercentage24H
        let marketCapstat = StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketCapChange)
        
        //row 2, col1
        let rank = "\(coinModel.rank)"
        let rankStat = StatisticModel(title: "Rank", value: rank)
        //row 2, col2
        let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "")
        let volumeStat = StatisticModel(title: "Volume", value: volume)
        
        let overViewArray: [StatisticModel] = [priceStat, marketCapstat, rankStat, volumeStat]
        
        return overViewArray
    
    }
    
    func createAdditionalArray(coinModel: CoinModel, coinDetailModel: CoinDetailModel?) -> [StatisticModel] {
        
        //row1, col 1
        let priceHigh24 = "\(coinModel.high24H?.asCurrencyWith6Decimals() ?? "N/A")"
        let highStat = StatisticModel(title: "24h High", value: priceHigh24)
        
        //row1, col 2
        let priceLow24 = "\(coinModel.low24H?.asCurrencyWith6Decimals() ?? "N/A")"
        let lowStat = StatisticModel(title: "24h Low", value: priceLow24)
        
        //row 2, col 1
        let priceChange24Curr = "\(coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "N/A")"
        let priceChange24Percent = coinModel.priceChangePercentage24H
        let priceChange24h = StatisticModel(title: "24h Price Change", value: "$\(priceChange24Curr)", percentageChange: priceChange24Percent)
        
        //row 2, col 2
        let priceMarketCapChange24Curr = "\(coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "0")"
        let priceMarketCapChange24Percent = coinModel.marketCapChangePercentage24H
        let priceMarketCapChange24h =  StatisticModel(title: "24h Market Cap Change", value: priceMarketCapChange24Curr, percentageChange: priceMarketCapChange24Percent)
        //row 3, col 1
        let blockTimeNumber = coinDetailModel?.blockTimeInMinutes
        let blockTime = StatisticModel(title: "Block Time", value: "\(blockTimeNumber ?? 0)")
        
        // row 3 col 2
        let algorithm = coinDetailModel?.hashingAlgorithm
        let hashingAlgorithm = StatisticModel(title: "Hashing Algorithm", value: algorithm ?? "N/A")
        
        let additionalArray: [StatisticModel] = [highStat, lowStat, priceChange24h, priceMarketCapChange24h, blockTime, hashingAlgorithm]
        
        return additionalArray
    }
}
