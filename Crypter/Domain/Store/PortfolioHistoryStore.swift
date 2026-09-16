//
//  PortfolioHistoryStore.swift
//  Crypter
//

import Foundation
import SwiftUI

struct PortfolioSnapshot: Identifiable, Equatable {
    let date: Date
    let value: Double

    var id: Date { date }
}

/// Records what the portfolio was worth, once a day.
///
/// The value of a past portfolio cannot be reconstructed from CoinGecko without
/// a historical price call per holding per day, so it is sampled going forward
/// instead. History therefore starts the day the app first runs.
final class PortfolioHistoryStore: ObservableObject {

    @Published private(set) var snapshots: [PortfolioSnapshot] = []

    private let defaults: UserDefaults
    private let storageKey: String
    private let calendar = Calendar.current
    private let retentionDays = 365

    init(defaults: UserDefaults = .standard, storageKey: String = "portfolio.history") {
        self.defaults = defaults
        self.storageKey = storageKey
        self.snapshots = Self.load(from: defaults, key: storageKey)
    }

    /// Replaces today's entry rather than appending, so the latest value wins.
    func record(value: Double, on date: Date = Date()) {
        guard value > 0 else { return }

        let day = calendar.startOfDay(for: date)
        var updated = snapshots.filter { !calendar.isDate($0.date, inSameDayAs: day) }
        updated.append(PortfolioSnapshot(date: day, value: value))
        updated.sort { $0.date < $1.date }

        if let cutoff = calendar.date(byAdding: .day, value: -retentionDays, to: day) {
            updated = updated.filter { $0.date >= cutoff }
        }

        snapshots = updated
        persist()
    }

    func snapshots(withinLast days: Int) -> [PortfolioSnapshot] {
        guard let cutoff = calendar.date(byAdding: .day, value: -days, to: calendar.startOfDay(for: Date())) else {
            return snapshots
        }

        return snapshots.filter { $0.date >= cutoff }
    }

    func change(withinLast days: Int) -> (amount: Double, percent: Double)? {
        let window = snapshots(withinLast: days)

        guard let first = window.first, let last = window.last, window.count > 1, first.value > 0 else {
            return nil
        }

        let amount = last.value - first.value
        return (amount, (amount / first.value) * 100)
    }

    func clear() {
        snapshots = []
        defaults.removeObject(forKey: storageKey)
    }

    private func persist() {
        let encoded = snapshots.reduce(into: [String: Double]()) { result, snapshot in
            result[String(Int(snapshot.date.timeIntervalSince1970))] = snapshot.value
        }

        defaults.set(encoded, forKey: storageKey)
    }

    private static func load(from defaults: UserDefaults, key: String) -> [PortfolioSnapshot] {
        guard let stored = defaults.dictionary(forKey: key) as? [String: Double] else { return [] }

        return stored
            .compactMap { key, value in
                guard let seconds = TimeInterval(key) else { return nil }
                return PortfolioSnapshot(date: Date(timeIntervalSince1970: seconds), value: value)
            }
            .sorted { $0.date < $1.date }
    }
}
