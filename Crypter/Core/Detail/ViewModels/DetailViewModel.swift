//
//  DetailViewModel.swift
//  Crypter
//
//  Created by Bishalw on 11/16/22.
//

import Foundation
import Combine
class DetailViewModel: ObservableObject{
    
    private let coinDetailDataService: CoinDetailDataService
    @Published var coin: CoinModel
    
    @Published var overViewStatistics: [StatisticModel] = []
    @Published var additionalStatistics: [StatisticModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, coinDetailDataService: CoinDetailDataService) {
        self.coin = coin
        self.coinDetailDataService = coinDetailDataService
        self.addSubscribers()
    }
  
   
    private func addSubscribers(){
        coinDetailDataService.$coinDetails
            .combineLatest($coin)
            .map({ (CoinDetailModel, coinModel) -> (overview: [StatisticModel], additional: [StatisticModel]) in
                
                // Overview Array
                
                //row1, col1
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
                
                //Additional Array
                
                //row1, col 1
                let priceHigh24 = coinModel.high24H
                let highStat = StatisticModel(title: "24h High", value: "$\(priceHigh24 ?? 0)")
                
                //row1, col 2
                let priceLow24 = coinModel.low24H
                let lowStat = StatisticModel(title: "24h Low", value: "$\(priceLow24 ?? 0)")
                
                //row 2, col 1
                let priceChange24Curr = coinModel.priceChange24H
                let priceChange24Percent = coinModel.priceChangePercentage24H
                let priceChange24h = StatisticModel(title: "24h Price Change", value: "$\(priceChange24Curr ?? 0)", percentageChange: priceChange24Percent)
                
                //row 2, col 2
                let priceMarketCapChange24Curr = coinModel.marketCapChange24H
                let priceMarketCapChange24Percent = coinModel.marketCapChangePercentage24H
                let priceMarketCapChange24h = StatisticModel(title: "24h Market Cap Change", value: "$\(priceMarketCapChange24Curr ?? 0)", percentageChange: priceMarketCapChange24Percent)
                
                //row 3, col 1
                let blockTimeNumber = CoinDetailModel?.blockTimeInMinutes
                let blockTime = StatisticModel(title: "Block Time", value: "\(blockTimeNumber ?? 0)")
                
                // row 3 col 2
                let algorithm = CoinDetailModel?.hashingAlgorithm
                let hashingAlgorithm = StatisticModel(title: "Hashing Algorithm", value: algorithm ?? "N/A")
                
                let additionalArray: [StatisticModel] = [highStat, lowStat, priceChange24h, priceMarketCapChange24h, blockTime, hashingAlgorithm]
                
                return (overViewArray,additionalArray)
            })
            .sink { [weak self](returnedArrays) in
                self?.overViewStatistics = returnedArrays.overview
                self?.additionalStatistics = returnedArrays.additional
            }
            .store(in: &cancellables)
        
    }
}
