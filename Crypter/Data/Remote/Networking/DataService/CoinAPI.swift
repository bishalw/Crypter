//
//  Constants.swift
//  Crypter
//
//

import Foundation
  
enum CoinAPI {
    case coins
    case coinDetails(coin: CoinModel)
    case coinImageURL(coin: CoinModel)
    case globalData

    var url: URL? {
        switch self {
        case .coins:
            return URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        case .coinDetails(let coin):
            return URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        case .coinImageURL(let coin):
            return URL(string: coin.image)
        case .globalData:
            return URL(string: "https://api.coingecko.com/api/v3/global")
        }
    }
}
