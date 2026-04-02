//
//  PortfolioAllocationChartView.swift
//  Crypter
//

import SwiftUI

struct PortfolioAllocationChartView: View {
    let coins: [CoinModel]
    let totalValue: Double

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
            return sorted.map { ChartItem(id: $0.id, symbol: $0.symbol.uppercased(), value: $0.currentHoldingsValue) }
        }
        var items = sorted.prefix(4).map { ChartItem(id: $0.id, symbol: $0.symbol.uppercased(), value: $0.currentHoldingsValue) }
        let othersValue = sorted.dropFirst(4).reduce(0.0) { $0 + $1.currentHoldingsValue }
        items.append(ChartItem(id: "others", symbol: "Others", value: othersValue))
        return items
    }

    private var slices: [(start: Double, end: Double)] {
        var result: [(start: Double, end: Double)] = []
        var current: Double = 0
        for item in displayItems {
            let pct = totalValue > 0 ? item.value / totalValue : 0
            let sweep = pct * 360
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
                .padding(.horizontal)
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
        .padding(.horizontal)
    }

    // MARK: - Chart Content

    private var chartContent: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                donutChart
                legendView
            }
            VStack(spacing: 16) {
                donutChart
                legendView
            }
        }
    }

    // MARK: - Donut Chart

    private var donutChart: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
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
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(minWidth: 120, idealWidth: 140, maxWidth: 160)
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                drawProgress = 1.0
            }
        }
    }

    // MARK: - Center Label

    @ViewBuilder
    private var centerLabel: some View {
        if let index = selectedIndex, index < displayItems.count {
            let item = displayItems[index]
            let pct = totalValue > 0 ? item.value / totalValue * 100 : 0
            VStack(spacing: 2) {
                Text(item.symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(String(format: "%.1f%%", pct))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(sliceColors[index % sliceColors.count])
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        } else {
            VStack(spacing: 2) {
                Text("Holdings")
                    .font(.caption2)
                    .foregroundColor(Color.theme.secondaryText)
                Text("\(coins.count)")
                    .font(.headline)
                    .foregroundColor(Color.theme.accent)
                Text(coins.count == 1 ? "coin" : "coins")
                    .font(.caption2)
                    .foregroundColor(Color.theme.secondaryText)
            }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    // MARK: - Legend

    private var legendView: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                let isSelected = selectedIndex == index
                let pct = totalValue > 0 ? item.value / totalValue * 100 : 0
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
                            Text(item.value.asCurrencyWith2Decimals())
                                .font(.caption2)
                                .foregroundColor(Color.theme.secondaryText)
                        }

                        Spacer()

                        Text(String(format: "%.1f%%", pct))
                            .font(.caption)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundColor(isSelected ? color : Color.theme.secondaryText)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isSelected ? color.opacity(0.12) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(item.symbol), \(String(format: "%.1f", pct)) percent, \(item.value.asCurrencyWith2Decimals())")
            }
        }
    }
}

// MARK: - Supporting Types

private struct ChartItem {
    let id: String
    let symbol: String
    let value: Double
}

private struct DonutSlice: Shape {
    var startDegrees: Double
    var endDegrees: Double
    var holeRatio: CGFloat = 0.55
    var angularInset: Double = 1.5
    /// Minimum visible sweep in degrees — slices smaller than this are rendered at this size
    private static let minimumSweep: Double = 6.0

    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startDegrees, endDegrees) }
        set { startDegrees = newValue.first; endDegrees = newValue.second }
    }

    func path(in rect: CGRect) -> Path {
        let rawSweep = endDegrees - startDegrees
        guard rawSweep > 0 else { return Path() }

        let effectiveSweep = max(rawSweep, Self.minimumSweep)
        let inset = min(angularInset, effectiveSweep / 3)

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * holeRatio
        let start = Angle.degrees(startDegrees + inset - 90)
        let end = Angle.degrees(startDegrees + effectiveSweep - inset - 90)

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

        Group {
            PortfolioAllocationChartView(coins: coins, totalValue: total)
                .previewDisplayName("With Data")

            PortfolioAllocationChartView(coins: [], totalValue: 0)
                .previewDisplayName("Empty State")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
