//
//  ChartView.swift
//  Crypter
//
//  Created by Bishalw on 6/19/24.
//

import Foundation
import SwiftUI
import Charts

struct ChartView: View {
    let data: [Double]
    let maxY: Double
    let minY: Double
    let dateFormatter = DateFormatter()
    let lineColor: Color
    let baselineY: Double
    let animation = CABasicAnimation(keyPath: "data")
    
    @State private var selectedIndex: Int? = nil
    @State private var showValue: Bool = false
    @State private var tapLocation: CGPoint = .zero
    
    init(coin: CoinModel) {
        data = coin.price  ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        animation.fromValue = data.first
        animation.toValue = data.last
        animation.duration = 2 // animate over 2 seconds
        baselineY = (maxY - minY) * 0.5 + minY
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            VStack {
                Chart {
                    ForEach(0..<data.count, id: \.self) { index in
                        LineMark(
                            x: .value("Index", index),
                            y: .value("Value", self.data[index])
                        )
                        .foregroundStyle(lineColor.gradient)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Index", index),
                            yStart: .value("Min", minY),
                            yEnd: .value("Value", data[index])
                        )
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [lineColor, .clear]), startPoint: .top, endPoint: .bottom))
                        .opacity(0.5)
                    }
                    if showValue {
                        RuleMark(y: .value("Baseline", baselineY))
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartYScale(domain: minY...maxY)
                .chartXAxis(content: {
                    let value = AxisMarkValues.automatic(minimumStride: 7, desiredCount: 7)
                    let date = Date()
                    let dayInSeconds = Double(60 * 60 * 24)
                    AxisMarks(values: value, content: { value in
                        switch value.index {
                        case 0:
                            AxisValueLabel(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 6))))
                        case 1:
                            AxisValueLabel(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 5))))
                        case 2:
                            AxisValueLabel(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 4))))
                        case 3:
                            AxisValueLabel(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 3))))
                        case 4:
                            AxisValueLabel(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 2))))
                        case 5:
                            AxisValueLabel(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - dayInSeconds)))
                        case 6:
                            AxisValueLabel(getDayOfTheWeek(date: date))
                        default:
                            AxisValueLabel()
                        }
                    })
                })
                .frame(height: 250)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { handleGestureChanged(value: $0) }
                        .onEnded { _ in
                            showValue = false
                        }
                    
                )
                .overlay(
                    Group {
                        if let selectedIndex = selectedIndex, showValue {
                            VStack {
                                Text("$ \(data[selectedIndex], specifier: "%.2f")")
                                    .font(.headline)
                                    .cornerRadius(5)
                                    .shadow(radius: 5)
                                Spacer()
                            }
                            .position(x: CGFloat(selectedIndex) * UIScreen.main.bounds.width / CGFloat(data.count), y: 100)
                        }
                    }
                )
            }
        } else {
            Text("Charts are supported in iOS 16.0. Please update :)")
        }
    }
    private func handleGestureChanged(value: DragGesture.Value) {
        let stepWidth = UIScreen.main.bounds.width / CGFloat(data.count)
        let tappedIndex = Int(value.location.x / stepWidth)
        if tappedIndex >= 0 && tappedIndex < data.count {
            selectedIndex = tappedIndex
            tapLocation = value.location
            showValue = true
        }
    }
}

extension ChartView {
    func getDayOfTheWeek(date: Date)-> String{
           dateFormatter.dateFormat = "EEE"
           let weekDay = dateFormatter.string(from: date)
           return weekDay
     }
}
