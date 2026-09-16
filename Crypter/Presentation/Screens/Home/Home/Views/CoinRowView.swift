//
//  CoinRowView.swift
//  Crypter
//


import SwiftUI
import Charts

struct CoinRowView: View {
    @EnvironmentObject var core: Core
    let coin: CoinModel
    let showHoldingsColumn: Bool
    var showSparkline: Bool = false
    var hidesValues: Bool = false

    static let maskedValue = "••••••"

    private var holdingsValueText: String {
        hidesValues ? Self.maskedValue : coin.currentHoldingsValue.asCurrencyWith2Decimals()
    }

    private var holdingsAmountText: String {
        guard !hidesValues else { return Self.maskedValue + " " + coin.symbol.uppercased() }

        let amount = NSNumber(value: coin.currentHoldings ?? 0)
        return (Self.amountFormatter.string(from: amount) ?? "0") + " " + coin.symbol.uppercased()
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
    }()

    private var priceText: String {
        coin.currentPrice >= 1000
            ? coin.currentPrice.asCurrencyWith2Decimals()
            : coin.currentPrice.asCurrencyWith6Decimals()
    }

    /// In the portfolio, all-time profit is the number that matters — fall back to
    /// the 24h move when the cost basis is unknown.
    private var showsAllTimeProfit: Bool {
        showHoldingsColumn && coin.totalProfitPercentage != nil
    }

    private var changeText: String {
        guard showsAllTimeProfit, let profit = coin.totalProfitPercentage else { return percentChangeText }
        return (profit >= 0 ? "+" : "") + profit.asPercentString()
    }

    private var changeColor: Color {
        let value = showsAllTimeProfit ? (coin.totalProfitPercentage ?? 0) : (coin.priceChangePercentage24H ?? 0)
        return value >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var percentChangeText: String {
        guard let change = coin.priceChangePercentage24H else { return "" }
        return (change >= 0 ? "+" : "") + change.asPercentString()
    }

    private var marketCapText: String {
        guard let marketCap = coin.marketCap else { return "" }
        return DisplayCurrency.current.symbol + marketCap.formattedWithAbbreviations()
    }

    var body: some View {
        HStack(spacing: 12) {
            leftColumn

            if showSparkline {
                CoinSparklineView(data: coin.price ?? [])
                    .frame(width: 60, height: 26)
            }

            rightColumn
        }
        .background(Color.theme.surfaceBackground.opacity(0.001))
    }
}

struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CoinRowView(coin: dev.coin, showHoldingsColumn: true)
                .previewLayout(.sizeThatFits)
        }
            CoinRowView(coin: dev.coin, showHoldingsColumn: false, showSparkline: true)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
extension CoinRowView {
    private var leftColumn: some View {
        HStack(spacing: 12) {
            if !showHoldingsColumn {
                Text("\(coin.rank)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.theme.textTertiary)
                    .frame(width: 16, alignment: .leading)
            }

            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: coin))
                .frame(width: 36, height: 36)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(coin.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if showHoldingsColumn {
                        Text(holdingsAmountText)
                    } else {
                        Text(coin.symbol.uppercased())
                        if !marketCapText.isEmpty {
                            Text("·")
                            Text(marketCapText)
                        }
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(Color.theme.textSecondary)
                .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rightColumn: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(showHoldingsColumn ? holdingsValueText : priceText)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)

            Text(changeText)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(changeColor)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct CoinSparklineView: View {
    let data: [Double]

    var body: some View {
        if data.isEmpty {
            Color.clear
        } else {
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, price in
                    LineMark(x: .value("Index", index), y: .value("Price", price))
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                        .foregroundStyle(SparklineStyle.lineColor(for: data))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: SparklineStyle.yScaleDomain(for: data))
            .chartPlotStyle { plotArea in
                plotArea.background(Color.clear)
            }
        }
    }
}
