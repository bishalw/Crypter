//
//  MockHomeViewModel.swift
//  Crypter
//
//  Created by Bishalw on 12/15/22.
//

import Foundation

class MockHomeViewModel: HomeViewModel {
    var sortOption: SortOption = .holdings
    
    func reloadData() {
    }
    
    var searchText: String = ""
    var statistics: [StatisticModel] = [stat1,stat2,stat3]
    var allCoins: [CoinModel] = [bitcoin,xrp,tron,etherium]
    var portfolioCoins: [CoinModel] = []
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
    }
}

extension MockHomeViewModel{
    
    static var bitcoin = CoinModel(id: "Bitcoin", symbol: "BTC", name: "", image: "", currentPrice: 0, marketCap: 0   , marketCapRank: 0, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "1", atl: 0, atlChangePercentage: 0, atlDate: "1", lastUpdated: "1", sparklineIn7D: nil , priceChangePercentage24HInCurrency: 0, currentHoldings: 0)
    static var xrp = CoinModel(id: "Xrp", symbol: "XRP", name: "", image: "", currentPrice: 0, marketCap: 0   , marketCapRank: 0, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "1", atl: 0, atlChangePercentage: 0, atlDate: "1", lastUpdated: "1", sparklineIn7D: nil , priceChangePercentage24HInCurrency: 0, currentHoldings: 0)
    static var tron = CoinModel(id: "Tron", symbol: "TRX", name: "", image: "", currentPrice: 0, marketCap: 0   , marketCapRank: 0, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "1", atl: 0, atlChangePercentage: 0, atlDate: "1", lastUpdated: "1", sparklineIn7D: nil , priceChangePercentage24HInCurrency: 0, currentHoldings: 0)
    static var etherium = CoinModel(id: "Etherium", symbol: "ETH", name: "", image: "", currentPrice: 0, marketCap: 0   , marketCapRank: 0, fullyDilutedValuation: 0, totalVolume: 0, high24H: 0, low24H: 0, priceChange24H: 0, priceChangePercentage24H: 0, marketCapChange24H: 0, marketCapChangePercentage24H: 0, circulatingSupply: 0, totalSupply: 0, maxSupply: 0, ath: 0, athChangePercentage: 0, athDate: "1", atl: 0, atlChangePercentage: 0, atlDate: "1", lastUpdated: "1", sparklineIn7D: nil , priceChangePercentage24HInCurrency: 0, currentHoldings: 0)
    
    static  let stat1 = StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34)
    static let stat2 = StatisticModel(title: "Total Volume", value: "$1.23Tr")
    static let stat3 = StatisticModel(title: "Portfolio Value", value: "$50.4k", percentageChange: -12.34)
}


