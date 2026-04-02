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
        54812.44719358261,
        55104.88273194627,
        54367.11842035794,
        53792.66418310583,
        54055.90327186412,
        54621.77590433849,
        55318.29461752073,
        54409.58173268144,
        53984.22619547318,
        54735.91028411652,
        55062.33194827584,
        54218.44762091377,
        53694.11850364295,
        54548.66917208431,
        55241.90836177562,
        54988.40217563914,
        54172.09358420186,
        53821.44719530847,
        54687.11293047528,
        55402.66381729456,
        53755.20849138064,
        54894.77035162981,
        55173.29164028547,
        54476.11820593726,
        53911.66287412045,
        54701.33841972619,
        55357.82049166402,
        54509.11733852078,
        54018.77419533721,
        54941.22851768493,
        55206.90318471534,
        54284.66097124389,
        53642.90715188452,
        54654.81270351987,
        55488.33019461548,
        54395.47266041835,
        53874.55123879016,
        55011.90476328174,
        54788.11639025463,
        54121.66384051794,
        53598.27460843127,
        54586.0381726954,
        55301.11758082491,
        54843.29567142038,
        53947.88261570329,
        54438.12059785261,
        55139.44728019352,
        54247.90638142608,
        53708.11946075283,
        54612.55093841764,
        55421.90863510273,
        54303.66184752094,
        53842.77019461826,
        54972.33841850741,
        55258.11439028675,
        54521.79340815784,
        54092.33871460517,
        54749.66021831954,
        55390.4415726842,
        54481.22765193877,
        53926.57302846188,
        54805.91364027546,
        55088.22419580631,
        54148.77930416257,
        53673.55081730428,
        54698.29145761083,
        55463.11729408639,
        54351.77690428166,
        53789.99218360457,
        54908.66517382024,
        55192.7730461859,
        54424.88357096143,
        54031.66274819356,
        54716.40238571985,
        55346.99162048528,
        54567.22849371461,
        53973.44108632547,
        54856.77402931804,
        55224.66081795318,
        54273.11764058291,
        53625.90347182674,
        54639.11828047125,
        55405.77296138466,
        54382.99471620573,
        53806.11739519442,
        54956.28394071831,
        55121.44763928055,
        54455.66028193754,
        54067.11849230588,
        54761.90413857063,
        55372.22840619487,
        54594.88327164029,
        53902.77516481346,
        54829.11640538275,
        55287.55018364941,
        54201.33857492863,
        53741.66492830592

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

    var totalPortfolio24hChange: Double {
        portfolioCoins.reduce(0) { $0 + ($1.priceChange24H ?? 0) * ($1.currentHoldings ?? 0) }
    }

    var totalPortfolio24hChangePercent: Double {
        let previousValue = totalPortfolioValue - totalPortfolio24hChange
        guard previousValue > 0 else { return 0 }
        return (totalPortfolio24hChange / previousValue) * 100
    }

    func updatePortfolio(coin: CoinModel, amount: Double) {
        if amount <= 0 {
            portfolioCoins.removeAll { $0.id == coin.id }
        }
    }
    
    func reloadData() {}
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

