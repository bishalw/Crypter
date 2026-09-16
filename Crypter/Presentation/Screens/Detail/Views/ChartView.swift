//
//  ChartView.swift
//  Crypter
//

import Foundation
import SwiftUI
import Charts

// MARK: - ChartView

struct ChartView: View {
    let coin: CoinModel
    let points: [ChartPoint]
    let isLoading: Bool
    let errorMessage: String?
    var onRangeChange: (ChartTimeRange) -> Void

    @State private var metrics: ChartMetrics
    @State private var selectedIndex: Int? = nil
    @State private var selectedTimeRange: ChartTimeRange = .week
    @State private var selectedReferenceLine: ChartReferenceLine = .none

    init(
        coin: CoinModel,
        points: [ChartPoint],
        isLoading: Bool,
        errorMessage: String?,
        onRangeChange: @escaping (ChartTimeRange) -> Void
    ) {
        self.coin = coin
        self.points = points
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.onRangeChange = onRangeChange
        _metrics = State(initialValue: ChartMetrics(points: points))
    }

    var body: some View {
        VStack(spacing: 16) {
            chartContent
                .opacity(isLoading ? 0.5 : 1.0)
                .overlay {
                    if isLoading && metrics.points.isEmpty {
                        ProgressView()
                            .tint(Color.theme.brandPrimary)
                    }
                }

            TimeRangePicker(selected: $selectedTimeRange)
                .onChange(of: selectedTimeRange) { _, newValue in
                    onRangeChange(newValue)
                    resetSelection()
                }

            if !metrics.points.isEmpty {
                ChartSummaryRow(metrics: metrics)

                Divider()
                    .overlay(Color.theme.borderSubtle)

                ReferenceLinePicker(
                    selected: $selectedReferenceLine,
                    options: availableReferenceLines
                )
            }
        }
        .onChange(of: points) { _, newPoints in
            metrics = ChartMetrics(points: newPoints)
            resetSelection()
        }
    }

    private var isPositiveTimeframe: Bool {
        metrics.isPositiveTimeframe
    }

    private var timeframeColor: Color {
        isPositiveTimeframe ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var yScaleDomain: ClosedRange<Double> {
        metrics.yScaleDomain
    }

    private var availableReferenceLines: [ChartReferenceLine] {
        var options: [ChartReferenceLine] = [.none]
        if metrics.startPrice != nil { options.append(.startPrice) }
        if metrics.currentPrice != nil { options.append(.currentPrice) }
        if let ath = coin.ath, yScaleDomain.contains(ath) { options.append(.ath) }
        if let high24H = coin.high24H, yScaleDomain.contains(high24H) { options.append(.high24h) }
        if let low24H = coin.low24H, yScaleDomain.contains(low24H) { options.append(.low24h) }
        return options
    }

    private var selectedPoint: ChartPoint? {
        guard let selectedIndex, metrics.points.indices.contains(selectedIndex) else { return nil }
        return metrics.points[selectedIndex]
    }

    @ViewBuilder
    private var chartContent: some View {
        if let errorMessage, metrics.points.isEmpty && !isLoading {
            ChartPlaceholderView(state: .error(errorMessage))
        } else if metrics.points.isEmpty && !isLoading {
            ChartPlaceholderView(state: .empty)
        } else {
            chartBody(data: metrics.points)
        }
    }

    private func chartBody(data: [ChartPoint]) -> some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { _, point in
                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Baseline", yScaleDomain.lowerBound),
                    yEnd: .value("Price", point.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [timeframeColor.opacity(0.28), timeframeColor.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(timeframeColor)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }

            if let value = referenceLineValue {
                RuleMark(y: .value("Reference", value))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.theme.brandPrimary.opacity(0.6))
                    .annotation(position: .top, alignment: .leading, spacing: 2) {
                        ChartBadge(text: selectedReferenceLine.rawValue, tint: Color.theme.brandPrimary)
                    }
            }

            if selectedPoint == nil {
                if let highPoint = metrics.highPoint {
                    PointMark(
                        x: .value("High date", highPoint.date),
                        y: .value("High", highPoint.price)
                    )
                    .symbolSize(0)
                    .annotation(
                        position: .top,
                        spacing: 4,
                        overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                    ) {
                        ChartBadge(text: "H " + Self.compact(highPoint.price))
                    }
                }

                if let lowPoint = metrics.lowPoint {
                    PointMark(
                        x: .value("Low date", lowPoint.date),
                        y: .value("Low", lowPoint.price)
                    )
                    .symbolSize(0)
                    .annotation(
                        position: .bottom,
                        spacing: 4,
                        overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
                    ) {
                        ChartBadge(text: "L " + Self.compact(lowPoint.price))
                    }
                }

                if let lastPoint = data.last {
                    PointMark(
                        x: .value("Latest date", lastPoint.date),
                        y: .value("Latest", lastPoint.price)
                    )
                    .symbolSize(60)
                    .foregroundStyle(timeframeColor)
                }
            }

            if let point = selectedPoint {
                RuleMark(x: .value("Selected", point.date))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .foregroundStyle(Color.theme.borderSubtle)

                PointMark(
                    x: .value("Selected Date", point.date),
                    y: .value("Selected Price", point.price)
                )
                .symbolSize(70)
                .foregroundStyle(timeframeColor)
                .annotation(
                    position: .top,
                    spacing: 10,
                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
                ) {
                    ChartTooltip(point: point, accentColor: timeframeColor)
                }

                PointMark(
                    x: .value("Selected Highlight", point.date),
                    y: .value("Selected Highlight Price", point.price)
                )
                .symbolSize(20)
                .foregroundStyle(Color.theme.surfaceBackground)
            }
        }
        .chartYScale(domain: yScaleDomain)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                    .foregroundStyle(Color.theme.borderSubtle.opacity(0.6))
            }
        }
        .chartPlotStyle { plotArea in
            plotArea.padding(.vertical, 12)
        }
        .frame(height: 200)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(value: value, proxy: proxy, geometry: geometry)
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.2)) { resetSelection() }
                            }
                    )
            }
        }
    }

    private func handleDrag(value: DragGesture.Value, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        let plotRect = geometry[plotFrame]
        let xPosition = value.location.x - plotRect.origin.x
        guard xPosition >= 0, xPosition <= plotRect.size.width else { return }

        guard let date: Date = proxy.value(atX: xPosition) else { return }

        let closestIndex = metrics.closestIndex(to: date)

        if let index = closestIndex, selectedIndex != index {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.82)) {
                selectedIndex = index
            }
        }
    }

    private func resetSelection() { selectedIndex = nil }

    private var referenceLineValue: Double? {
        guard availableReferenceLines.contains(selectedReferenceLine) else { return nil }
        switch selectedReferenceLine {
        case .none: return nil
        case .startPrice: return metrics.startPrice
        case .currentPrice: return metrics.currentPrice
        case .ath: return coin.ath
        case .high24h: return coin.high24H
        case .low24h: return coin.low24H
        }
    }

    fileprivate static func compact(_ value: Double) -> String {
        abs(value) >= 1000 ? DisplayCurrency.current.symbol + value.formattedWithAbbreviations() : value.asCurrencyWith2Decimals()
    }
}

private struct ChartMetrics {
    let points: [ChartPoint]
    let dates: [Date]
    let yScaleDomain: ClosedRange<Double>
    let startPrice: Double?
    let currentPrice: Double?
    let highPrice: Double?
    let lowPrice: Double?
    let highPoint: ChartPoint?
    let lowPoint: ChartPoint?
    let changePercent: Double
    let isPositiveTimeframe: Bool

    init(points: [ChartPoint]) {
        self.points = points
        self.dates = points.map(\.date)
        self.startPrice = points.first?.price
        self.currentPrice = points.last?.price
        self.highPoint = points.max(by: { $0.price < $1.price })
        self.lowPoint = points.min(by: { $0.price < $1.price })
        self.highPrice = highPoint?.price
        self.lowPrice = lowPoint?.price

        if let startPrice, let currentPrice, startPrice > 0 {
            self.changePercent = ((currentPrice - startPrice) / startPrice) * 100
        } else {
            self.changePercent = 0
        }

        if let startPrice, let currentPrice {
            self.isPositiveTimeframe = currentPrice >= startPrice
        } else {
            self.isPositiveTimeframe = true
        }

        self.yScaleDomain = SparklineStyle.yScaleDomain(for: points.map(\.price))
    }

    func closestIndex(to date: Date) -> Int? {
        guard !dates.isEmpty else { return nil }
        var low = 0
        var high = dates.count

        while low < high {
            let mid = (low + high) / 2
            if dates[mid] < date {
                low = mid + 1
            } else {
                high = mid
            }
        }

        if low == 0 { return 0 }
        if low == dates.count { return dates.count - 1 }

        let previousIndex = low - 1
        let nextIndex = low
        let previousDistance = abs(dates[previousIndex].timeIntervalSince(date))
        let nextDistance = abs(dates[nextIndex].timeIntervalSince(date))
        return previousDistance <= nextDistance ? previousIndex : nextIndex
    }
}

// MARK: - Components

/// Small pill used for the high / low / reference callouts drawn on the chart.
private struct ChartBadge: View {
    let text: String
    var tint: Color = Color.theme.textSecondary

    var body: some View {
        Text(text)
            .font(.system(size: 10, design: .monospaced))
            .foregroundColor(tint)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.theme.surfaceTertiary)
            )
    }
}

struct TimeRangePicker: View {
    @Binding var selected: ChartTimeRange
    @Namespace private var rangeNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChartTimeRange.availableCases) { range in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { selected = range }
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selected == range ? Color.theme.textPrimary : Color.theme.textTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background {
                            if selected == range {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.theme.surfaceTertiary)
                                    .matchedGeometryEffect(id: "range_background", in: rangeNamespace)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
    }
}

struct ReferenceLinePicker: View {
    @Binding var selected: ChartReferenceLine
    let options: [ChartReferenceLine]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options) { line in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selected = (line == .none) ? .none : (selected == line ? .none : line)
                        }
                    } label: {
                        Text(line.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selected == line ? Color.theme.brandPrimary : Color.theme.textSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(selected == line ? Color.theme.brandSoft : Color.theme.surfaceSecondary)
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(
                                                selected == line ? Color.theme.brandPrimary : Color.theme.borderSubtle,
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
    }
}

struct ChartTooltip: View {
    let point: ChartPoint
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(point.date.asShortDateString())
                .font(.system(size: 10))
                .foregroundColor(Color.theme.textTertiary)

            Text(point.price.asCurrencyWith2Decimals())
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.theme.surfaceTertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(accentColor.opacity(0.4), lineWidth: 1)
                )
        )
    }
}

private struct ChartSummaryRow: View {
    let metrics: ChartMetrics

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            summaryItem(label: "Start", value: ChartView.compact(metrics.startPrice ?? 0))
            Spacer(minLength: 0)
            summaryItem(label: "High", value: ChartView.compact(metrics.highPrice ?? 0))
            Spacer(minLength: 0)
            summaryItem(label: "Low", value: ChartView.compact(metrics.lowPrice ?? 0))
            Spacer(minLength: 0)
            summaryItem(
                label: "Change",
                value: (metrics.changePercent >= 0 ? "+" : "") + metrics.changePercent.asPercentString(),
                tint: metrics.changePercent >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
            )
        }
        .contentTransition(.numericText())
    }

    private func summaryItem(label: String, value: String, tint: Color = Color.theme.textPrimary) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

struct MiniSparklineView: View {
    let data: [Double]

    var body: some View {
        if data.isEmpty {
            placeholder
        } else {
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { i, p in
                    LineMark(x: .value("I", i), y: .value("P", p))
                        .foregroundStyle(SparklineStyle.lineColor(for: data))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.theme.surfaceSecondary)
            )
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.theme.surfaceSecondary)
            .overlay(
                Text("No data")
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textTertiary)
            )
    }
}

struct ChartPlaceholderView: View {
    enum State {
        case empty
        case error(String)
    }

    let state: State

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 28))
                .foregroundColor(Color.theme.textTertiary)

            Text(title)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.theme.textSecondary)
                .padding(.horizontal, 24)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.theme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private var title: String {
        switch state {
        case .empty:
            return "No price data available"
        case .error(let message):
            return message
        }
    }
}
