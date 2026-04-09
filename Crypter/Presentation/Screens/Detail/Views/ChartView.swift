//
//  ChartView.swift
//  Crypter
//
//  Created by Bishalw on 6/19/24.
//

import Foundation
import SwiftUI
import Charts

// MARK: - Time Range

enum ChartTimeRange: String, CaseIterable, Identifiable {
    case day = "24H"
    case week = "7D"
    case month = "30D"
    case year = "1Y"
    case all = "ALL"

    var id: String { rawValue }
}

// MARK: - Reference Line

enum ChartReferenceLine: String, CaseIterable, Identifiable {
    case none = "None"
    case startPrice = "Start"
    case currentPrice = "Current"
    case ath = "ATH"
    case high24h = "24h High"
    case low24h = "24h Low"

    var id: String { rawValue }
}

// MARK: - Chart State

enum ChartDataState {
    case empty
    case loaded([Double])
}

// MARK: - Shared Sparkline Helpers

enum SparklineStyle {
    static func lineColor(for data: [Double]) -> Color {
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        return priceChange >= 0 ? Color.theme.green : Color.theme.red
    }

    static func yScaleDomain(for data: [Double]) -> ClosedRange<Double> {
        guard let minValue = data.min(), let maxValue = data.max() else {
            return 0...1
        }

        if minValue == maxValue {
            let inset = Swift.max(1, abs(maxValue) * 0.02)
            return (minValue - inset)...(maxValue + inset)
        }

        let padding = Swift.max((maxValue - minValue) * 0.12, 1)
        return (minValue - padding)...(maxValue + padding)
    }
}

struct MiniSparklineView: View {
    let data: [Double]

    private var lineColor: Color {
        SparklineStyle.lineColor(for: data)
    }

    private var yScaleDomain: ClosedRange<Double> {
        SparklineStyle.yScaleDomain(for: data)
    }

    var body: some View {
        Group {
            if data.isEmpty {
                placeholder
            } else if #available(iOS 16, *) {
                chartBody
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.theme.background)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundColor(Color.theme.secondaryText.opacity(0.6))
                    Text("7D chart unavailable")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            .frame(height: 120)
    }

    @available(iOS 16, *)
    private var chartBody: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, price in
                AreaMark(
                    x: .value("Index", index),
                    yStart: .value("Baseline", yScaleDomain.lowerBound),
                    yEnd: .value("Price", price)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [lineColor.opacity(0.28), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Index", index),
                    y: .value("Price", price)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(lineColor.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
        }
        .chartXScale(domain: 0...(max(data.count - 1, 1)))
        .chartYScale(domain: yScaleDomain)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 120)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.theme.secondaryText.opacity(0.08), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Seven day price trend")
    }
}

// MARK: - ChartView

struct ChartView: View {

    private static let dayRangePointFloor = 12

    let coin: CoinModel
    let allData: [Double]

    @State private var selectedIndex: Int? = nil
    @State private var selectedTimeRange: ChartTimeRange = .week
    @State private var selectedReferenceLine: ChartReferenceLine = .none

    init(coin: CoinModel) {
        self.coin = coin
        self.allData = coin.price ?? []
    }

    var body: some View {
        VStack(spacing: 16) {
            TimeRangePicker(selected: $selectedTimeRange)
            
            chartContent
                .padding(.top, 4)

            if case .loaded(let displayData) = chartDataState {
                VStack(spacing: 16) {
                    ChartSummaryRow(data: displayData)
                    
                    Divider()
                        .padding(.horizontal)
                        .opacity(0.5)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reference Lines")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.secondaryText)
                            .padding(.horizontal)
                        
                        ReferenceLinePicker(
                            selected: $selectedReferenceLine,
                            options: availableReferenceLines
                        )
                    }
                }
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.background)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.theme.secondaryText.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var chartDataState: ChartDataState {
        displayData.isEmpty ? .empty : .loaded(displayData)
    }

    private var isPositiveTimeframe: Bool {
        guard let first = displayData.first, let last = displayData.last else { return true }
        return last >= first
    }

    private var timeframeColor: Color {
        isPositiveTimeframe ? Color.theme.green : Color.theme.red
    }

    private var displayData: [Double] {
        switch selectedTimeRange {
        case .day:
            let count = max(Self.dayRangePointFloor, allData.count / 4)
            return Array(allData.suffix(count))
        case .week, .month, .year, .all:
            return allData
        }
    }

    private var yScaleDomain: ClosedRange<Double> {
        SparklineStyle.yScaleDomain(for: displayData)
    }

    private var availableReferenceLines: [ChartReferenceLine] {
        var options: [ChartReferenceLine] = [.none]

        if displayData.first != nil {
            options.append(.startPrice)
        }

        if displayData.last != nil {
            options.append(.currentPrice)
        }

        if let ath = coin.ath, yScaleDomain.contains(ath) {
            options.append(.ath)
        }

        if let high24H = coin.high24H, yScaleDomain.contains(high24H) {
            options.append(.high24h)
        }

        if let low24H = coin.low24H, yScaleDomain.contains(low24H) {
            options.append(.low24h)
        }

        return options
    }

    private var selectedPrice: Double? {
        guard let selectedIndex, displayData.indices.contains(selectedIndex) else { return nil }
        return displayData[selectedIndex]
    }

    private var selectedPriceText: String {
        selectedPrice?.asCurrencyWith2Decimals() ?? ""
    }

    private var hasHoldings: Bool {
        (coin.currentHoldings ?? 0) > 0
    }

    @ViewBuilder
    private var chartContent: some View {
        switch chartDataState {
        case .empty:
            ChartPlaceholderView(
                state: .empty,
                rangeLabel: selectedTimeRange.rawValue
            )
        case .loaded(let displayData):
            if #available(iOS 16, *) {
                chartBody(data: displayData)
            } else {
                Text("Charts require iOS 16.0+")
                    .font(.callout)
                    .foregroundColor(Color.theme.secondaryText)
                    .frame(height: 250)
            }
        }
    }

    @available(iOS 16, *)
    private func chartBody(data: [Double]) -> some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, price in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Price", price)
                )
                .foregroundStyle(timeframeColor.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Index", index),
                    yStart: .value("Baseline", yScaleDomain.lowerBound),
                    yEnd: .value("Price", price)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [timeframeColor.opacity(0.35), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }

            if let value = referenceLineValue {
                RuleMark(y: .value("Reference", value))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(timeframeColor.opacity(0.6))
            }

            if let selectedIndex, displayData.indices.contains(selectedIndex) {
                RuleMark(x: .value("Selected", selectedIndex))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    .foregroundStyle(Color.theme.secondaryText.opacity(0.45))

                PointMark(
                    x: .value("Selected Index", selectedIndex),
                    y: .value("Selected Price", displayData[selectedIndex])
                )
                .symbolSize(70)
                .foregroundStyle(timeframeColor)
                .annotation(position: .top, spacing: 10) {
                    ChartTooltip(price: displayData[selectedIndex], accentColor: timeframeColor)
                }

                PointMark(
                    x: .value("Selected Highlight", selectedIndex),
                    y: .value("Selected Highlight Price", displayData[selectedIndex])
                )
                .symbolSize(20)
                .foregroundStyle(Color.white)
            }
        }
        .chartYScale(domain: yScaleDomain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(Color.theme.secondaryText.opacity(0.18))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(doubleValue.asCurrencyWith2Decimals())
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(Color.theme.secondaryText)
                    }
                }
            }
        }
        .frame(height: 250)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleDrag(value: value, proxy: proxy, geometry: geometry)
                                }
                                .onEnded { _ in
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        resetSelection()
                                    }
                                }
                        )
                    
                    if let value = referenceLineValue,
                       let yPosition = proxy.position(forY: value) {
                        Text(selectedReferenceLine.rawValue)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(timeframeColor)
                            .clipShape(Capsule())
                            .offset(y: yPosition - 10)
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(chartAccessibilityLabel)
        .accessibilityValue(selectedPriceText.isEmpty ? selectedTimeRange.rawValue : "Selected price \(selectedPriceText)")
    }

    private var chartSurface: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.theme.background)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.theme.secondaryText.opacity(0.08), lineWidth: 1)
            )
    }

    @available(iOS 16, *)
    private func handleDrag(
        value: DragGesture.Value,
        proxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        guard let plotFrame = proxy.plotFrame else { return }

        let plotRect = geometry[plotFrame]
        let xPosition = value.location.x - plotRect.origin.x
        guard xPosition >= 0, xPosition <= plotRect.size.width else { return }
        guard let index: Int = proxy.value(atX: xPosition) else { return }

        let clampedIndex = max(0, min(index, displayData.count - 1))
        
        if selectedIndex != clampedIndex {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.82)) {
                selectedIndex = clampedIndex
            }
        }
    }

    private func resetSelection() {
        selectedIndex = nil
    }

    private var referenceLineValue: Double? {
        guard availableReferenceLines.contains(selectedReferenceLine) else { return nil }

        switch selectedReferenceLine {
        case .none:
            return nil
        case .startPrice:
            return displayData.first
        case .currentPrice:
            return displayData.last
        case .ath:
            return coin.ath
        case .high24h:
            return coin.high24H
        case .low24h:
            return coin.low24H
        }
    }

    private var chartAccessibilityLabel: String {
        guard let first = displayData.first, let last = displayData.last, first != 0 else {
            return "Price chart, no data available"
        }

        let change = ((last - first) / first) * 100
        let trend = change >= 0 ? "up" : "down"
        return "Price chart for \(coin.name), \(selectedTimeRange.rawValue) view, trending \(trend) \(abs(change).asPercentString()). Current price \(last.asCurrencyWith2Decimals())"
    }
}

// MARK: - Time Range Picker

struct TimeRangePicker: View {
    @Binding var selected: ChartTimeRange

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChartTimeRange.allCases) { range in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selected = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(selected == range ? .bold : .medium)
                        .foregroundColor(selected == range ? Color.theme.accent : Color.theme.secondaryText)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selected == range {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.theme.accent.opacity(0.15))
                                        .matchedGeometryEffect(id: "range_background", in: rangeNamespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color.theme.secondaryText.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
    @Namespace private var rangeNamespace
}

// MARK: - Reference Line Picker

struct ReferenceLinePicker: View {
    @Binding var selected: ChartReferenceLine
    let options: [ChartReferenceLine]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options) { line in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if line == .none {
                                selected = .none
                            } else {
                                selected = (selected == line) ? .none : line
                            }
                        }
                    } label: {
                        Text(line.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(selected == line ? Color.theme.accent : Color.theme.secondaryText)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selected == line ? Color.theme.accent.opacity(0.12) : Color.theme.background)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selected == line ? Color.theme.accent : Color.theme.secondaryText.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Chart Tooltip

struct ChartTooltip: View {
    let price: Double
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Price")
                .font(.caption2)
                .foregroundColor(Color.theme.secondaryText)
            Text(price.asCurrencyWith2Decimals())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.accent)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.background)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Selected price \(price.asCurrencyWith2Decimals())")
    }
}

// MARK: - Chart Summary Row

struct ChartSummaryRow: View {
    let data: [Double]

    private var startPrice: Double { data.first ?? 0 }
    private var currentPrice: Double { data.last ?? 0 }
    private var highPrice: Double { data.max() ?? 0 }
    private var lowPrice: Double { data.min() ?? 0 }
    private var changePercent: Double {
        guard startPrice > 0 else { return 0 }
        return ((currentPrice - startPrice) / startPrice) * 100
    }

    var body: some View {
        HStack {
            summaryItem(label: "Start", value: compactCurrency(startPrice))
            Spacer()
            summaryItem(label: "Current", value: compactCurrency(currentPrice))
            Spacer()
            summaryItem(label: "High", value: compactCurrency(highPrice))
            Spacer()
            summaryItem(label: "Low", value: compactCurrency(lowPrice))
            Spacer()
            VStack(spacing: 2) {
                Text("Change")
                    .font(.caption2)
                    .foregroundColor(Color.theme.secondaryText)
                Text(changePercent.asPercentString())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(changePercent >= 0 ? Color.theme.green : Color.theme.red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .monospacedDigit()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Change \(changePercent.asPercentString())")
        }
        .padding(.horizontal)
    }

    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(Color.theme.secondaryText)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value)")
    }

    private func compactCurrency(_ value: Double) -> String {
        abs(value) >= 1_000 ? "$\(value.formattedWithAbbreviations())" : value.asCurrencyWith2Decimals()
    }
}

// MARK: - Chart Placeholder View

struct ChartPlaceholderView: View {
    enum State {
        case empty
    }

    let state: State
    let rangeLabel: String

    var body: some View {
        VStack(spacing: 12) {
            switch state {
            case .empty:
                Image(systemName: "chart.line.downtrend.xyaxis")
                    .font(.system(size: 36))
                    .foregroundColor(Color.theme.secondaryText.opacity(0.5))
                Text("No price data available")
                    .font(.callout)
                    .foregroundColor(Color.theme.secondaryText)
                Text("No \(rangeLabel) chart data is available for this coin yet.")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.theme.secondaryText.opacity(0.03))
        )
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No \(rangeLabel) price data available for this coin")
    }
}

// MARK: - Previews

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChartView(coin: DeveloperPreview.instance.coin)
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("With Data (Holdings)")

            ChartView(coin: CoinModel(
                id: "empty", symbol: "---", name: "No Data Coin",
                image: "", currentPrice: 0,
                marketCap: nil, marketCapRank: nil, fullyDilutedValuation: nil,
                totalVolume: nil, high24H: nil, low24H: nil,
                priceChange24H: nil, priceChangePercentage24H: nil,
                marketCapChange24H: nil, marketCapChangePercentage24H: nil,
                circulatingSupply: nil, totalSupply: nil, maxSupply: nil,
                ath: nil, athChangePercentage: nil, athDate: nil,
                atl: nil, atlChangePercentage: nil, atlDate: nil,
                lastUpdated: nil, price: [],
                priceChangePercentage24HInCurrency: nil, currentHoldings: nil
            ))
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Empty State")
        }
    }
}
