//
//  PortfolioAllocationChartView.swift
//  Crypter
//

import SwiftUI

struct PortfolioAllocationChartView: View {
    let coins: [CoinModel]
    let totalValue: Double
    let totalChange: Double

    @State private var selectedIndex: Int? = nil
    @State private var drawProgress: Double = 0
    @Environment(\.colorScheme) private var colorScheme

    private let sliceColors: [Color] = [
        Color(red: 0.30, green: 0.78, blue: 0.55),  // mint green
        Color(red: 0.36, green: 0.53, blue: 0.95),  // royal blue
        Color(red: 0.95, green: 0.62, blue: 0.27),  // warm amber
        Color(red: 0.68, green: 0.42, blue: 0.90),  // soft violet
        Color(red: 0.92, green: 0.40, blue: 0.53),  // coral pink
        Color(red: 0.25, green: 0.72, blue: 0.78),  // teal
        Color(red: 0.95, green: 0.80, blue: 0.30),  // gold
    ]

    private var displayItems: [ChartItem] {
        let sorted = coins.sorted { $0.currentHoldingsValue > $1.currentHoldingsValue }
        if sorted.count <= 5 {
            return sorted.map { coin in
                ChartItem(
                    id: coin.id,
                    label: coin.symbol.uppercased(),
                    symbol: coin.symbol.uppercased(),
                    value: coin.currentHoldingsValue,
                    percentage: percentage(for: coin.currentHoldingsValue),
                    isAggregate: false
                )
            }
        }
        var items = sorted.prefix(4).map { coin in
            ChartItem(
                id: coin.id,
                label: coin.symbol.uppercased(),
                symbol: coin.symbol.uppercased(),
                value: coin.currentHoldingsValue,
                percentage: percentage(for: coin.currentHoldingsValue),
                isAggregate: false
            )
        }
        let othersValue = sorted.dropFirst(4).reduce(0.0) { $0 + $1.currentHoldingsValue }
        items.append(
            ChartItem(
                id: "others",
                label: "Other Holdings",
                symbol: "Others",
                value: othersValue,
                percentage: percentage(for: othersValue),
                isAggregate: true
            )
        )
        return items
    }

    private var slices: [(start: Double, end: Double)] {
        var result: [(start: Double, end: Double)] = []
        var current: Double = 0
        for item in displayItems {
            let sweep = item.percentage * 360
            result.append((current, current + sweep))
            current += sweep
        }
        return result
    }

    private var totalChangeColor: Color {
        if totalChange > 0 {
            return Color.theme.green
        } else if totalChange < 0 {
            return Color.theme.red
        } else {
            return Color.theme.secondaryText
        }
    }

    var body: some View {
        if coins.isEmpty || totalValue <= 0 {
            emptyState
        } else {
            chartContent
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(
                            color: colorScheme == .dark
                                ? Color.black.opacity(0.3)
                                : Color.black.opacity(0.06),
                            radius: 12, x: 0, y: 4
                        )
                )
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.pie")
                .font(.largeTitle)
                .foregroundColor(Color.theme.secondaryText.opacity(0.5))
            Text("No allocation data")
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Chart Content

    private var chartContent: some View {
        ViewThatFits(in: .horizontal) {
            regularChartContent
            compactChartContent
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Donut Chart

    private func donutChart(size: CGFloat) -> some View {
        ZStack {
            ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                let isSelected = selectedIndex == index
                let sliceDelay = Double(index) * 0.12

                DonutSlice(
                    startDegrees: min(slice.start, drawProgress * 360),
                    endDegrees: min(slice.end, drawProgress * 360),
                    angularInset: 1.5
                )
                .fill(sliceColors[index % sliceColors.count])
                .scaleEffect(isSelected ? 1.07 : 1.0)
                .opacity(selectedIndex == nil || isSelected ? 1.0 : 0.35)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedIndex)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedIndex = selectedIndex == index ? nil : index
                    }
                }
                .animation(
                    .easeOut(duration: 0.7).delay(sliceDelay),
                    value: drawProgress
                )
            }
            centerLabel
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selectedIndex)
                .frame(width: size * 0.54)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                drawProgress = 1.0
            }
        }
    }

    private var regularChartContent: some View {
        HStack(alignment: .center, spacing: 24) {
            donutChart(size: 156)
            legendView
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var compactChartContent: some View {
        VStack(spacing: 18) {
            donutChart(size: 188)
            legendView
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Center Label

    @ViewBuilder
    private var centerLabel: some View {
        if let index = selectedIndex, index < displayItems.count {
            let item = displayItems[index]
            VStack(spacing: 3) {
                Text(item.label)
                    .font(.caption.weight(.semibold))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(percentageText(for: item.percentage))
                    .font(.caption2.weight(.medium))
                    .fontWeight(.medium)
                    .foregroundColor(sliceColors[index % sliceColors.count])
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(item.value.asCompactCurrency())
                    .font(.caption2)
                    .foregroundColor(Color.theme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                    .monospacedDigit()
            }
            .multilineTextAlignment(.center)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        } else {
            VStack(spacing: 3) {
                Text(totalValue.asCompactCurrency())
                    .font(.headline.weight(.semibold))
                    .foregroundColor(Color.theme.accent)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(totalChange.asSignedCompactCurrency())
                    .font(.caption2)
                    .foregroundColor(totalChangeColor)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .multilineTextAlignment(.center)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    // MARK: - Legend

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                let isSelected = selectedIndex == index
                let color = sliceColors[index % sliceColors.count]

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedIndex = selectedIndex == index ? nil : index
                    }
                } label: {
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(color)
                            .frame(width: 12, height: 12)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.symbol)
                                .font(.caption)
                                .fontWeight(isSelected ? .bold : .medium)
                                .foregroundColor(Color.theme.accent)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(item.value.asCompactCurrency())
                                .font(.caption2)
                                .foregroundColor(Color.theme.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .monospacedDigit()
                        }

                        Spacer(minLength: 12)

                        Text(percentageText(for: item.percentage))
                            .font(.caption)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundColor(isSelected ? color : Color.theme.secondaryText)
                            .monospacedDigit()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isSelected ? color.opacity(0.12) : Color.clear)
                    )
                }
                .opacity(selectedIndex == nil || isSelected ? 1.0 : 0.62)
                .buttonStyle(.plain)
                .accessibilityLabel(accessibilityLabel(for: item))
            }
        }
    }

    private func percentage(for value: Double) -> Double {
        guard totalValue > 0 else { return 0 }
        return value / totalValue
    }

    private func percentageText(for ratio: Double) -> String {
        guard ratio > 0 else { return "0.0%" }
        let percent = ratio * 100
        return percent < 0.1 ? "<0.1%" : String(format: "%.1f%%", percent)
    }

    private func accessibilityLabel(for item: ChartItem) -> String {
        let prefix = item.isAggregate ? "Other holdings, combined smaller holdings" : item.symbol
        return "\(prefix), \(percentageText(for: item.percentage)), \(item.value.asCompactCurrency())"
    }
}

// MARK: - Supporting Types

private struct ChartItem {
    let id: String
    let label: String
    let symbol: String
    let value: Double
    let percentage: Double
    let isAggregate: Bool
}

private struct DonutSlice: Shape {
    var startDegrees: Double
    var endDegrees: Double
    var holeRatio: CGFloat = 0.49
    var angularInset: Double = 1.5

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startDegrees, endDegrees) }
        set { startDegrees = newValue.first; endDegrees = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let sweep = endDegrees - startDegrees
        guard sweep > 0 else { return Path() }

        let inset = min(angularInset, sweep / 3)

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * holeRatio
        let start = Angle.degrees(startDegrees + inset - 90)
        let end = Angle.degrees(endDegrees - inset - 90)

        var path = Path()
        path.addArc(center: center, radius: outerRadius, startAngle: start, endAngle: end, clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: end, endAngle: start, clockwise: true)
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

struct PortfolioAllocationChartView_Previews: PreviewProvider {
    static var previews: some View {
        let dev = DeveloperPreview.instance
        let coins = [
            dev.coin.updateHoldings(amount: 1.5),
            dev.coin2.updateHoldings(amount: 10.0)
        ]
        let total = coins.map { $0.currentHoldingsValue }.reduce(0, +)
        let totalChange = coins.reduce(0) { $0 + (($1.priceChange24H ?? 0) * ($1.currentHoldings ?? 0)) }

        Group {
            PortfolioAllocationChartView(coins: coins, totalValue: total, totalChange: totalChange)
                .previewDisplayName("With Data")

            PortfolioAllocationChartView(coins: [], totalValue: 0, totalChange: 0)
                .previewDisplayName("Empty State")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
