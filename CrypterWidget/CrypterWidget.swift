//
//  CrypterWidget.swift
//  CrypterWidget
//

import WidgetKit
import SwiftUI

// The widget runs in its own process and shares no code with the app, so it
// carries a small copy of what it needs: the palette and one API call.
private enum WidgetTheme {
    static let background = Color(red: 0.039, green: 0.043, blue: 0.055)
    static let surface = Color(red: 0.082, green: 0.090, blue: 0.110)
    static let textPrimary = Color(red: 0.953, green: 0.957, blue: 0.965)
    static let textSecondary = Color(red: 0.545, green: 0.573, blue: 0.627)
    static let accent = Color(red: 0.616, green: 0.549, blue: 1.0)
    static let up = Color(red: 0.204, green: 0.827, blue: 0.600)
    static let down = Color(red: 0.973, green: 0.443, blue: 0.443)
}

struct WidgetCoin: Identifiable {
    let id: String
    let symbol: String
    let name: String
    let price: Double
    let change24h: Double

    var isUp: Bool { change24h >= 0 }

    var priceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = UserDefaults.standard.string(forKey: "displayCurrency")?.uppercased() ?? "USD"
        formatter.maximumFractionDigits = price >= 1 ? 2 : 6
        return formatter.string(from: NSNumber(value: price)) ?? "—"
    }

    var changeText: String {
        String(format: "%@%.2f%%", isUp ? "+" : "", change24h)
    }
}

private struct MarketCoinDTO: Decodable {
    let id: String
    let symbol: String
    let name: String
    let current_price: Double?
    let price_change_percentage_24h: Double?
}

private enum MarketFetcher {
    static func topCoins() async -> [WidgetCoin] {
        let currency = UserDefaults.standard.string(forKey: "displayCurrency") ?? "usd"
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=\(currency)&order=market_cap_desc&per_page=4&page=1"

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let dtos = try JSONDecoder().decode([MarketCoinDTO].self, from: data)

            return dtos.map {
                WidgetCoin(
                    id: $0.id,
                    symbol: $0.symbol.uppercased(),
                    name: $0.name,
                    price: $0.current_price ?? 0,
                    change24h: $0.price_change_percentage_24h ?? 0
                )
            }
        } catch {
            return []
        }
    }
}

struct MarketEntry: TimelineEntry {
    let date: Date
    let coins: [WidgetCoin]
}

struct MarketProvider: TimelineProvider {
    private static let placeholderCoins = [
        WidgetCoin(id: "bitcoin", symbol: "BTC", name: "Bitcoin", price: 75_000, change24h: 1.8),
        WidgetCoin(id: "ethereum", symbol: "ETH", name: "Ethereum", price: 2_400, change24h: -0.9),
        WidgetCoin(id: "solana", symbol: "SOL", name: "Solana", price: 97, change24h: 3.4),
    ]

    func placeholder(in context: Context) -> MarketEntry {
        MarketEntry(date: Date(), coins: Self.placeholderCoins)
    }

    func getSnapshot(in context: Context, completion: @escaping (MarketEntry) -> Void) {
        if context.isPreview {
            completion(MarketEntry(date: Date(), coins: Self.placeholderCoins))
            return
        }

        Task {
            let coins = await MarketFetcher.topCoins()
            completion(MarketEntry(date: Date(), coins: coins.isEmpty ? Self.placeholderCoins : coins))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MarketEntry>) -> Void) {
        Task {
            let coins = await MarketFetcher.topCoins()
            let entry = MarketEntry(date: Date(), coins: coins)
            // Half-hourly keeps prices current without burning the free tier's
            // rate limit or the widget's refresh budget.
            let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }
}

struct CrypterWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: MarketEntry

    private var visibleCoins: [WidgetCoin] {
        Array(entry.coins.prefix(family == .systemSmall ? 1 : 3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 6 : 10) {
            if family != .systemSmall {
                Text("Markets")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(WidgetTheme.textSecondary)
            }

            if visibleCoins.isEmpty {
                Text("Couldn't load prices")
                    .font(.system(size: 12))
                    .foregroundColor(WidgetTheme.textSecondary)
            } else {
                ForEach(visibleCoins) { coin in
                    if family == .systemSmall {
                        smallRow(coin)
                    } else {
                        row(coin)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .containerBackground(WidgetTheme.background, for: .widget)
    }

    private func smallRow(_ coin: WidgetCoin) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(coin.symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(WidgetTheme.textSecondary)

            Text(coin.priceText)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundColor(WidgetTheme.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(coin.changeText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(coin.isUp ? WidgetTheme.up : WidgetTheme.down)
        }
    }

    private func row(_ coin: WidgetCoin) -> some View {
        HStack(spacing: 8) {
            Text(coin.symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(WidgetTheme.textPrimary)
                .frame(width: 44, alignment: .leading)

            Text(coin.priceText)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(WidgetTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 4)

            Text(coin.changeText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(coin.isUp ? WidgetTheme.up : WidgetTheme.down)
        }
    }
}

struct CrypterWidget: Widget {
    let kind = "CrypterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarketProvider()) { entry in
            CrypterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Markets")
        .description("Live prices for the largest coins.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct CrypterWidgetBundle: WidgetBundle {
    var body: some Widget {
        CrypterWidget()
    }
}
