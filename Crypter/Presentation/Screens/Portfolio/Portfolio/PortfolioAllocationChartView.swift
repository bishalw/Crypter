//
//  PortfolioAllocationChartView.swift
//  Crypter
//

import SwiftUI

struct PortfolioAllocationChartView: View {
    let coins: [CoinModel]
    let totalValue: Double
    let totalChange: Double
    var hidesValues: Bool = false

    @State private var selectedIndex: Int? = nil
    @State private var drawProgress: Double = 0
    @Environment(\.colorScheme) private var colorScheme

    // Allocation slices, tuned to sit alongside the pen's purple accent.
    private let sliceColors: [Color] = [
        Color(hex: "#9D8CFF"),
        Color(hex: "#34D399"),
        Color(hex: "#F7931A"),
        Color(hex: "#627EEA"),
        Color(hex: "#F87171"),
        Color(hex: "#38BDF8"),
        Color(hex: "#FBBF24"),
    ]

    private var displayItems: [ChartItem] { /* ... Existing Logic remains unchanged ... */
        let sorted = coins.sorted { $0.currentHoldingsValue > $1.currentHoldingsValue }
        if sorted.count <= 5 {
            return sorted.map { ChartItem(id: $0.id, label: $0.name, symbol: $0.symbol.uppercased(), value: $0.currentHoldingsValue, percentage: percentage(for: $0.currentHoldingsValue), isAggregate: false) }
        }
        var items = sorted.prefix(4).map { ChartItem(id: $0.id, label: $0.name, symbol: $0.symbol.uppercased(), value: $0.currentHoldingsValue, percentage: percentage(for: $0.currentHoldingsValue), isAggregate: false) }
        let othersValue = sorted.dropFirst(4).reduce(0.0) { $0 + $1.currentHoldingsValue }
        items.append(ChartItem(id: "others", label: "Other", symbol: "Other", value: othersValue, percentage: percentage(for: othersValue), isAggregate: true))
        return items
    }

    private var slices: [(start: Double, end: Double)] { /* ... Existing Logic ... */
        var result: [(start: Double, end: Double)] = []
        var current: Double = 0
        for item in displayItems {
            let sweep = item.percentage * 360
            result.append((current, current + sweep))
            current += sweep
        }
        return result
    }

    var body: some View {
        if coins.isEmpty || totalValue <= 0 {
            emptyState
        } else {
            chartContent
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.theme.surfaceSecondary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.theme.borderSubtle, lineWidth: 1)
                )
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.theme.textTertiary)
            Text("No allocation data")
                .font(.callout.weight(.medium))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
    }

    
    // MARK: - Chart Content
    private var chartContent: some View {
        HStack(alignment: .center, spacing: 22) {
            donutChart(size: 124)

            legendView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Legend
    private var legendView: some View {
        VStack(alignment: .leading, spacing: 11) {
            ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                let isSelected = selectedIndex == index
                let color = sliceColors[index % sliceColors.count]

                Button {
                    toggleSelection(index)
                } label: {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(color)
                            .frame(width: 8, height: 8)

                        Text(item.label)
                            .font(.system(size: 13))
                            .foregroundColor(isSelected ? Color.theme.textPrimary : Color.theme.textSecondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(percentageText(for: item.percentage))
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.theme.textPrimary)
                            .lineLimit(1)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .opacity(selectedIndex == nil || isSelected ? 1.0 : 0.4)
                .accessibilityLabel(accessibilityLabel(for: item))
            }
        }
    }

    private func toggleSelection(_ index: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            selectedIndex = selectedIndex == index ? nil : index
        }
        if selectedIndex != nil {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    private func donutChart(size: CGFloat) -> some View {
        ZStack {
            ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                let isSelected = selectedIndex == index
                let sliceColor = sliceColors[index % sliceColors.count]

                DonutSlice(
                    startDegrees: min(slice.start, drawProgress * 360),
                    endDegrees: min(slice.end, drawProgress * 360),
                    angularInset: 0.8
                )
                .fill(sliceColor)
                .opacity(selectedIndex == nil || isSelected ? 1.0 : 0.4)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedIndex)
                .onTapGesture {
                    toggleSelection(index)
                }
                .animation(.easeOut(duration: 0.8).delay(Double(index) * 0.08), value: drawProgress)
            }
            
            centerLabel
                .frame(width: size * 0.55)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { drawProgress = 1.0 }
        }
    }

    @ViewBuilder
    private var centerLabel: some View {
        VStack(spacing: 2) {
            if let index = selectedIndex, index < displayItems.count {
                let item = displayItems[index]
                Text(percentageText(for: item.percentage))
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                Text(hidesValues ? CoinRowView.maskedValue : item.value.asCompactCurrency())
                    .font(.system(size: 11))
                    .foregroundColor(Color.theme.textSecondary)
            } else {
                Text("\(coins.count)")
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                Text(coins.count == 1 ? "asset" : "assets")
                    .font(.system(size: 11))
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .multilineTextAlignment(.center)
        .contentTransition(.numericText())
    }

    // ... [Helper functions percentage(), percentageText() remain the same]


// ... [ChartItem & DonutSlice & Previews remain the same]

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
    var holeRatio: CGFloat = 0.74
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
