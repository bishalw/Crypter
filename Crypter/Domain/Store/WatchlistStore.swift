//
//  WatchlistStore.swift
//  Crypter
//

import Foundation
import SwiftUI

/// Ordered list of coins the user is watching.
///
/// The order is the user's own (they can drag rows in the Watchlist tab), so it
/// is stored as an array rather than a set.
final class WatchlistStore: ObservableObject {

    @Published private(set) var coinIDs: [String] = []

    private let defaults: UserDefaults
    private let storageKey: String

    init(defaults: UserDefaults = .standard, storageKey: String = "watchlist.coinIDs") {
        self.defaults = defaults
        self.storageKey = storageKey
        self.coinIDs = defaults.stringArray(forKey: storageKey) ?? []
    }

    func contains(_ coin: CoinModel) -> Bool {
        coinIDs.contains(coin.id)
    }

    /// Adds the coin to the end of the list, matching how Stocks appends a new symbol.
    func add(_ coin: CoinModel) {
        guard !coinIDs.contains(coin.id) else { return }

        coinIDs.append(coin.id)
        persist()
    }

    func remove(_ coin: CoinModel) {
        remove(id: coin.id)
    }

    func remove(id: String) {
        guard let index = coinIDs.firstIndex(of: id) else { return }

        coinIDs.remove(at: index)
        persist()
    }

    /// Returns true when the coin ended up on the watchlist, so callers can pick a haptic.
    @discardableResult
    func toggle(_ coin: CoinModel) -> Bool {
        if contains(coin) {
            remove(coin)
            return false
        }

        add(coin)
        return true
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        coinIDs.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    func removeAll(atOffsets offsets: IndexSet) {
        coinIDs.remove(atOffsets: offsets)
        persist()
    }

    /// Resolves the stored ids against the live coin list, keeping the user's order.
    func coins(from allCoins: [CoinModel]) -> [CoinModel] {
        let coinsByID = Dictionary(allCoins.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        return coinIDs.compactMap { coinsByID[$0] }
    }

    private func persist() {
        defaults.set(coinIDs, forKey: storageKey)
    }
}
