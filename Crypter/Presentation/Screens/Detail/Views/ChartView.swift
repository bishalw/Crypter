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
            TimeRangePicker(selected: $selectedTimeRange)
                .onChange(of: selectedTimeRange) { newValue in
                    onRangeChange(newValue)
                    resetSelection()
                }
            
            chartContent
                .padding(.top, 4)
                .opacity(isLoading ? 0.6 : 1.0)
                .overlay {
                    if isLoading && metrics.points.isEmpty {
                        ProgressView()
                            .tint(Color.theme.brandPrimary)
                    }
                }

            if !metrics.points.isEmpty {
                VStack(spacing: 16) {
                    ChartSummaryRow(metrics: metrics)
                    
                    Divider()
                        .overlay(Color.theme.borderSubtle)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reference Lines")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.textSecondary)
                            .padding(.horizontal)
                        
                        ReferenceLinePicker(
                            selected: $selectedReferenceLine,
                            options: availableReferenceLines
                        )
                    }
                }
            }
        }
        .onChange(of: points) { newPoints in
            metrics = ChartMetrics(points: newPoints)
            resetSelection()
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.theme.borderSubtle, lineWidth: 1)
                )
        )
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
            ChartPlaceholderView(state: .error(errorMessage), rangeLabel: selectedTimeRange.rawValue)
        } else if metrics.points.isEmpty && !isLoading {
            ChartPlaceholderView(state: .empty, rangeLabel: selectedTimeRange.rawValue)
        } else if #available(iOS 16, *) {
            chartBody(data: metrics.points)
        } else {
            Text("Charts require iOS 16.0+")
                .foregroundColor(Color.theme.textSecondary)
                .frame(height: 250)
        }
    }

    @available(iOS 16, *)
    private func chartBody(data: [ChartPoint]) -> some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(timeframeColor.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", point.date),
                    yStart: .value("Baseline", yScaleDomain.lowerBound),
                    yEnd: .value("Price", point.price)
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
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                .foregroundStyle(timeframeColor.opacity(0.4))
            }

            if let point = selectedPoint {
                RuleMark(x: .value("Selected", point.date))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    .foregroundStyle(Color.theme.textSecondary.opacity(0.45))

                PointMark(
                    x: .value("Selected Date", point.date),
                    y: .value("Selected Price", point.price)
                )
                .symbolSize(70)
                .foregroundStyle(timeframeColor)
                .annotation(position: .top, spacing: 10) {
                    ChartTooltip(point: point, accentColor: timeframeColor)
                }

                PointMark(
                    x: .value("Selected Highlight", point.date),
                    y: .value("Selected Highlight Price", point.price)
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
                    .foregroundStyle(Color.theme.textSecondary.opacity(0.18))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(doubleValue.asCurrencyWith2Decimals())
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(Color.theme.textSecondary)
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
                                    withAnimation(.easeOut(duration: 0.2)) { resetSelection() }
                                }
                        )
                    
                    if let value = referenceLineValue, let yPosition = proxy.position(forY: value) {
                        Text(selectedReferenceLine.rawValue)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(timeframeColor))
                            .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                            .offset(y: yPosition - 12)
                    }
                }
            }
        }
    }

    @available(iOS 16, *)
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
}

private struct ChartMetrics {
    let points: [ChartPoint]
    let dates: [Date]
    let yScaleDomain: ClosedRange<Double>
    let startPrice: Double?
    let currentPrice: Double?
    let highPrice: Double?
    let lowPrice: Double?
    let changePercent: Double
    let isPositiveTimeframe: Bool

    init(points: [ChartPoint]) {
        self.points = points
        self.dates = points.map(\.date)
        self.startPrice = points.first?.price
        self.currentPrice = points.last?.price
        self.highPrice = points.map(\.price).max()
        self.lowPrice = points.map(\.price).min()

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

struct TimeRangePicker: View {
    @Binding var selected: ChartTimeRange
    @Namespace private var rangeNamespace
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ChartTimeRange.availableCases) { range in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selected = range }
                } label: {
                    Text(range.rawValue)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(selected == range ? .bold : .medium)
                        .foregroundColor(selected == range ? Color.theme.brandPrimary : Color.theme.textSecondary)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(ZStack {
                            if selected == range {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.theme.brandPrimary.opacity(0.15))
                                    .matchedGeometryEffect(id: "range_background", in: rangeNamespace)
                            }
                        })
                }
            }
        }
        .padding(4)
        .background(Color.theme.textSecondary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

struct ReferenceLinePicker: View {
    @Binding var selected: ChartReferenceLine
    let options: [ChartReferenceLine]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options) { line in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = (line == .none) ? .none : (selected == line ? .none : line)
                        }
                    } label: {
                        Text(line.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(selected == line ? Color.theme.brandPrimary : Color.theme.textSecondary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 8).fill(selected == line ? Color.theme.brandPrimary.opacity(0.12) : Color.theme.surfaceSecondary))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected == line ? Color.theme.brandPrimary : Color.theme.textSecondary.opacity(0.2), lineWidth: 1))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
    }
}

struct ChartTooltip: View {
    let point: ChartPoint
    let accentColor: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(point.date.asShortDateString())
                .font(.system(size: 8))
                .foregroundColor(Color.theme.textSecondary)
            Text(point.price.asCurrencyWith2Decimals())
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.brandPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.theme.surfaceSecondary))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(accentColor.opacity(0.3), lineWidth: 1))
    }
}

private struct ChartSummaryRow: View {
    let metrics: ChartMetrics
    var body: some View {
        HStack {
            summaryItem(label: "Start", value: format(metrics.startPrice ?? 0))
            Spacer(); summaryItem(label: "High", value: format(metrics.highPrice ?? 0))
            Spacer(); summaryItem(label: "Low", value: format(metrics.lowPrice ?? 0))
            Spacer(); VStack(spacing: 2) {
                Text("Change").font(.caption2).foregroundColor(Color.theme.textSecondary)
                Text(metrics.changePercent.asPercentString()).font(.caption).fontWeight(.semibold).foregroundColor(metrics.changePercent >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger)
            }
        }.padding(.horizontal)
    }
    private func summaryItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundColor(Color.theme.textSecondary)
            Text(value).font(.caption).fontWeight(.semibold).foregroundColor(Color.theme.textPrimary)
        }
    }
    private func format(_ v: Double) -> String { abs(v) >= 1000 ? "$\(v.formattedWithAbbreviations())" : v.asCurrencyWith2Decimals() }
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
                        .foregroundStyle(SparklineStyle.lineColor(for: data).gradient)
                }
            }
            .chartXAxis(.hidden).chartYAxis(.hidden).frame(height: 120)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.theme.surfaceSecondary))
        }
    }
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 14).fill(Color.theme.surfaceSecondary)
            .overlay(Text("No data").font(.caption).foregroundColor(Color.theme.textSecondary))
    }
}

struct ChartPlaceholderView: View {
    enum State {
        case empty
        case error(String)
    }

    let state: State; let rangeLabel: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.downtrend.xyaxis").font(.system(size: 36)).foregroundColor(Color.theme.textSecondary.opacity(0.5))
            Text(title).font(.callout).foregroundColor(Color.theme.textSecondary)
        }
        .frame(height: 250).frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.theme.textSecondary.opacity(0.03)))
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
