//
//  PortfolioAllocationChartView.swift
//  Crypter
//

import SwiftUI

import SwiftUI

struct PortfolioAllocationChartView: View {
    let coins: [CoinModel]
    let totalValue: Double
    let totalChange: Double

    @State private var selectedIndex: Int? = nil
    @State private var drawProgress: Double = 0
    @Environment(\.colorScheme) private var colorScheme

    private let sliceColors: [Color] = [
        Color(red: 0.30, green: 0.78, blue: 0.55),
        Color(red: 0.36, green: 0.53, blue: 0.95),
        Color(red: 0.95, green: 0.62, blue: 0.27),
        Color(red: 0.68, green: 0.42, blue: 0.90),
        Color(red: 0.92, green: 0.40, blue: 0.53),
        Color(red: 0.25, green: 0.72, blue: 0.78),
        Color(red: 0.95, green: 0.80, blue: 0.30),
    ]

    private var displayItems: [ChartItem] { /* ... Existing Logic remains unchanged ... */
        let sorted = coins.sorted { $0.currentHoldingsValue > $1.currentHoldingsValue }
        if sorted.count <= 5 {
            return sorted.map { ChartItem(id: $0.id, label: $0.symbol.uppercased(), symbol: $0.symbol.uppercased(), value: $0.currentHoldingsValue, percentage: percentage(for: $0.currentHoldingsValue), isAggregate: false) }
        }
        var items = sorted.prefix(4).map { ChartItem(id: $0.id, label: $0.symbol.uppercased(), symbol: $0.symbol.uppercased(), value: $0.currentHoldingsValue, percentage: percentage(for: $0.currentHoldingsValue), isAggregate: false) }
        let othersValue = sorted.dropFirst(4).reduce(0.0) { $0 + $1.currentHoldingsValue }
        items.append(ChartItem(id: "others", label: "Other Holdings", symbol: "Others", value: othersValue, percentage: percentage(for: othersValue), isAggregate: true))
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

    private var totalChangeColor: Color {
        totalChange > 0 ? Color.theme.statusSuccess : (totalChange < 0 ? Color.theme.statusDanger : Color.theme.textSecondary)
    }

    var body: some View {
        if coins.isEmpty || totalValue <= 0 {
            emptyState
        } else {
            chartContent
                .padding(20) // Increased padding for breathing room
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.theme.surfaceSecondary)
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.theme.borderSubtle, lineWidth: 1)
                )
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.theme.textSecondary.opacity(0.3))
            Text("No allocation data")
                .font(.callout.weight(.medium))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
    }

    
    // MARK: - Chart Content
        private var chartContent: some View {
            // Tighter spacing between chart and legend
            HStack(alignment: .center, spacing: 16) {
                // Reduced size slightly to give the legend more horizontal room
                donutChart(size: 110)
                
                legendView
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        // MARK: - Legend
        private var legendView: some View {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
                    let isSelected = selectedIndex == index
                    let color = sliceColors[index % sliceColors.count]

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedIndex = selectedIndex == index ? nil : index
                            if selectedIndex != nil {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    } label: {
                        HStack(spacing: 8) { // Tighter spacing between dot and text
                            Circle()
                                .fill(color)
                                .frame(width: 8, height: 8) // Slightly smaller dot

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.symbol)
                                    // Scaled down the font slightly
                                    .font(.subheadline.weight(isSelected ? .bold : .semibold))
                                    .foregroundColor(Color.theme.textPrimary)
                                    // CRITICAL: Stop the wrapping
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                
                                Text(item.value.asCompactCurrency())
                                    .font(.caption2)
                                    .foregroundColor(Color.theme.textSecondary)
                                    // CRITICAL: Stop the wrapping
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }

                            // CRITICAL: Reduce the minimum length so it doesn't push text away
                            Spacer(minLength: 4)

                            Text(percentageText(for: item.percentage))
                                .font(.subheadline.weight(isSelected ? .bold : .semibold))
                                .foregroundColor(isSelected ? color : Color.theme.textSecondary)
                                // CRITICAL: Stop the wrapping
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .monospacedDigit()
                        // Reduced horizontal padding so it fits better
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isSelected ? color.opacity(0.15) : Color.clear)
                        )
                    }
                    .opacity(selectedIndex == nil || isSelected ? 1.0 : 0.4)
                    .buttonStyle(.plain)
                }
            }
        }
        // You can now DELETE regularChartContent and compactChartContent!

    private func donutChart(size: CGFloat) -> some View {
        ZStack {
            // Subtle inner background to define the "hole" better
            Circle()
                .fill(Color.theme.brandPrimary.opacity(0.03))
                .frame(width: size * 0.7)
                .blur(radius: 5)

            ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                let isSelected = selectedIndex == index
                let sliceColor = sliceColors[index % sliceColors.count]

                DonutSlice(
                    startDegrees: min(slice.start, drawProgress * 360),
                    endDegrees: min(slice.end, drawProgress * 360),
                    angularInset: 0.8
                )
                .fill(
                    LinearGradient(
                        colors: [sliceColor, sliceColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                     DonutSlice(startDegrees: min(slice.start, drawProgress * 360), endDegrees: min(slice.end, drawProgress * 360), angularInset: 0.8)
                        .stroke(Color.theme.surfaceBackground, lineWidth: 2)
                )
                .scaleEffect(isSelected ? 1.08 : 1.0)
                .opacity(selectedIndex == nil || isSelected ? 1.0 : 0.4)
                .shadow(color: isSelected ? sliceColor.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedIndex)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        selectedIndex = selectedIndex == index ? nil : index
                        if selectedIndex != nil {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                }
                .animation(.easeOut(duration: 0.8).delay(Double(index) * 0.08), value: drawProgress)
            }
            
            centerLabel
                .frame(width: size * 0.58)
        }
        .padding(12)
        .frame(width: size + 24, height: size + 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { drawProgress = 1.0 }
        }
    }

    private var regularChartContent: some View {
        HStack(alignment: .center, spacing: 20) {
            donutChart(size: 150)
            legendView
        }
    }

    private var compactChartContent: some View {
        VStack(spacing: 24) {
            donutChart(size: 170)
            legendView
        }
    }

    @ViewBuilder
    private var centerLabel: some View {
        VStack(spacing: 0) {
            if let index = selectedIndex, index < displayItems.count {
                let item = displayItems[index]
                Text(item.symbol)
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textSecondary)
                
                Text(percentageText(for: item.percentage))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(sliceColors[index % sliceColors.count])
                
                Text(item.value.asCompactCurrency())
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
            } else {
                Text("TOTAL")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textSecondary)
                
                Text(totalValue.asCompactCurrency())
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)
                
                HStack(spacing: 2) {
                    Image(systemName: totalChange >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 8, weight: .bold))
                    Text(totalChange.asSignedCompactCurrency())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                }
                .foregroundColor(totalChangeColor)
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
    var holeRatio: CGFloat = 0.65
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
