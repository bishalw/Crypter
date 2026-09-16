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
    case marketChart(coinID: String, days: String)
    case trending
    /// Name/symbol search across every coin, not just the first page of markets.
    case search(query: String)
    /// Market data for a specific set of coin ids, used to price search results.
    case markets(ids: [String])

    var url: URL? {
        switch self {
        case .coins:
            return URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(DisplayCurrency.current.apiCode)&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        case .coinDetails(let coin):
            return URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        case .coinImageURL(let coin):
            return URL(string: coin.image)
        case .globalData:
            return URL(string: "https://api.coingecko.com/api/v3/global")
        case .marketChart(let coinID, let days):
            return URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=\(DisplayCurrency.current.apiCode)&days=\(days)")
        case .trending:
            return URL(string: "https://api.coingecko.com/api/v3/search/trending")
        case .search(let query):
            guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return URL(string: "https://api.coingecko.com/api/v3/search?query=\(encoded)")
        case .markets(let ids):
            guard !ids.isEmpty,
                  let encoded = ids.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }
            return URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(DisplayCurrency.current.apiCode)&ids=\(encoded)&sparkline=true&price_change_percentage=24h")
        }
    }
}
