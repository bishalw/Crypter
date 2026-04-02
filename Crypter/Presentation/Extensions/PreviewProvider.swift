//
//  PreviewProvider.swift
//  Crypter
//

//

import Foundation
import SwiftUI
import Combine

extension PreviewProvider {

    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

class DeveloperPreview {

    static let instance = DeveloperPreview()
    private init() { }
    let coin = CoinModel(
       id: "bitcoin",
       symbol: "btc",
       name: "Bitcoin",
       image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
       currentPrice: 61408,
       marketCap: 1141731099010,
       marketCapRank: 1,
       fullyDilutedValuation: 1285385611303,
       totalVolume: 67190952980,
       high24H: 61712,
       low24H: 56220,
       priceChange24H: 3952.64,
       priceChangePercentage24H: 6.87944,
       marketCapChange24H: 72110681879,
       marketCapChangePercentage24H: 6.74171,
       circulatingSupply: 18653043,
       totalSupply: 21000000,
       maxSupply: 21000000,
       ath: 61712,
       athChangePercentage: -0.97589,
       athDate: "2021-03-13T20:49:26.606Z",
       atl: 67.81,
       atlChangePercentage: 90020.24075,
       atlDate: "2013-07-06T00:00:00.000Z",
       lastUpdated: "2021-03-13T23:18:10.268Z",
       price: [
           54019.26878317463,
           53718.060935791524,
           53677.12968669343,
           53848.3814432924,
           53561.593235320615,
           53456.0913723206,
           53888.97184353125,
           54796.37233913172,
           54593.507358383504,
           54582.558599307624,
           54635.7248282177,
           54772.612788430226,
           54954.0493828267,
           54910.13413954234,
           54778.58411728141,
           55027.87934987173,
           55473.0657777974,
           54696.044114623706,

       ],
       priceChangePercentage24HInCurrency: 3952.64,
       currentHoldings: 1.5)

    let coin2 = CoinModel(
       id: "ethereum",
       symbol: "eth",
       name: "Ethereum",
       image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880",
       currentPrice: 1811.36,
       marketCap: 211505994380,
       marketCapRank: 2,
       fullyDilutedValuation: nil,
       totalVolume: 20886718139,
       high24H: 1824.28,
       low24H: 1718.81,
       priceChange24H: 68.77,
       priceChangePercentage24H: 3.94,
       marketCapChange24H: 8198519612,
       marketCapChangePercentage24H: 4.03,
       circulatingSupply: 115250583,
       totalSupply: nil,
       maxSupply: nil,
       ath: 4356.99,
       athChangePercentage: -58.42,
       athDate: "2021-11-10T14:24:19.604Z",
       atl: 0.432979,
       atlChangePercentage: 418270.93,
       atlDate: "2015-10-20T00:00:00.000Z",
       lastUpdated: "2021-03-13T23:18:10.268Z",
       price: [
           1750.12, 1762.34, 1758.90, 1771.23, 1780.45,
           1775.68, 1790.12, 1795.34, 1801.56, 1798.78,
           1805.90, 1810.12, 1808.34, 1811.56, 1809.78,
       ],
       priceChangePercentage24HInCurrency: 68.77,
       currentHoldings: 10.0)

    let stat1 = StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34)
    let stat2 = StatisticModel(title: "Total Volume", value: "$1.23Tr")
    let stat3 = StatisticModel(title: "Portfolio Value", value: "$50.4k", percentageChange: -12.34)
    static let stat1 = StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34)
    static let stat2 = StatisticModel(title: "Total Volume", value: "$1.23Tr")
    static let stat3 = StatisticModel(title: "Portfolio Value", value: "$50.4k", percentageChange: -12.34)
}

// MARK: - Mock CryptoStore

class MockCryptoStore: CryptoStore {
    var coins: CurrentValueSubject<[CoinModel]?, Never>
    var coinDetails: CurrentValueSubject<CoinDetailModel?, Never>
    var globalDetails: CurrentValueSubject<MarketDataModel?, Never>

    init(
        coins: [CoinModel]? = CoinModel.mockCoins(),
        coinDetails: CoinDetailModel? = nil,
        globalDetails: MarketDataModel? = MarketDataModel.mockMarketDataModel()
    ) {
        self.coins = CurrentValueSubject(coins)
        self.coinDetails = CurrentValueSubject(coinDetails)
        self.globalDetails = CurrentValueSubject(globalDetails)
    }

    func fetchAllCoins() {}
    func fetchCoinDetails(coin: CoinModel) {}
    func fetchGlobalData() {}
}

// MARK: - Preview ViewModels

class PreviewHomeViewModel: HomeViewModel {
    @Published var statistics: [StatisticModel]
    @Published var allCoins: [CoinModel]
    @Published var portfolioCoins: [CoinModel]
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .rank

    init() {
        let dev = DeveloperPreview.instance
        self.statistics = [dev.stat1, dev.stat2, dev.stat3]
        self.allCoins = [dev.coin, dev.coin2]
        self.portfolioCoins = [dev.coin.updateHoldings(amount: 1.5)]
    }

    var myTotalHoldingDisplayString: String {
        let total = portfolioCoins.map { $0.currentHoldingsValue }.reduce(0, +)
        return "$\(total.formattedWithAbbreviations())"
    }

    func updatePortfolio(coin: CoinModel, amount: Double) {}
    func reloadData() {}
}

class PreviewPortfolioViewModel: PortfolioViewModel {
    @Published var portfolioCoins: [CoinModel]

    init(empty: Bool = false) {
        if empty {
            self.portfolioCoins = []
        } else {
            let dev = DeveloperPreview.instance
            self.portfolioCoins = [
                dev.coin.updateHoldings(amount: 1.5),
                dev.coin2.updateHoldings(amount: 10.0),
            ]
        }
    }

    var totalPortfolioValue: Double {
        portfolioCoins.map { $0.currentHoldingsValue }.reduce(0, +)
    }

    var myTotalHoldingDisplayString: String {
        "$\(totalPortfolioValue.formattedWithAbbreviations())"
    }
}

class PreviewDetailViewModel: DetailViewModel {
    @Published var overViewStatistics: [StatisticModel]
    @Published var additionalStatistics: [StatisticModel]
    @Published var coin: CoinModel
    @Published var coinDescription: String?
    @Published var websiteURL: String?
    @Published var redditURL: String?

    init(coin: CoinModel = DeveloperPreview.instance.coin) {
        self.coin = coin
        self.overViewStatistics = [
            StatisticModel(title: "Current Price", value: coin.currentPrice.asCurrencyWith6Decimals(), percentageChange: coin.priceChangePercentage24H),
            StatisticModel(title: "Market Cap", value: "$\((coin.marketCap ?? 0).formattedWithAbbreviations())", percentageChange: coin.marketCapChangePercentage24H),
            StatisticModel(title: "Rank", value: "\(coin.rank)"),
            StatisticModel(title: "Volume", value: "$\((coin.totalVolume ?? 0).formattedWithAbbreviations())"),
        ]
        self.additionalStatistics = [
            StatisticModel(title: "24h High", value: coin.high24H?.asCurrencyWith6Decimals() ?? "N/A"),
            StatisticModel(title: "24h Low", value: coin.low24H?.asCurrencyWith6Decimals() ?? "N/A"),
            StatisticModel(title: "24h Price Change", value: coin.priceChange24H?.asCurrencyWith6Decimals() ?? "N/A", percentageChange: coin.priceChangePercentage24H),
            StatisticModel(title: "Block Time", value: "10"),
            StatisticModel(title: "Hashing Algorithm", value: "SHA-256"),
        ]
        self.coinDescription = "Bitcoin is the first successful internet money based on peer-to-peer technology. No central bank or authority controls the supply of bitcoins."
        self.websiteURL = "https://bitcoin.org"
        self.redditURL = "https://reddit.com/r/bitcoin"
    }
}

// MARK: - Preview Core

extension Core {
    static var preview: Core {
        Core()
    }
}

