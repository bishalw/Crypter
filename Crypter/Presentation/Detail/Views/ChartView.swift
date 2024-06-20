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
    let animation = CABasicAnimation(keyPath: "data")
    
    init(coin: CoinModel) {
        
        data = coin.price  ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        animation.fromValue = data.first
        animation.toValue = data.last
        animation.duration = 2 // animate over 2 seconds
    }
    
    var body: some View{
        
        if #available(iOS 16, *) {
            Chart {
                ForEach(0..<data.count, id: \.self) { index in
                    
                    LineMark(
                        x: .value("",index),
                        y: .value("",self.data[index])
                    )
                    .foregroundStyle(lineColor.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("",index),
                        yStart: .value("",minY),
                        yEnd:.value("", data[index])
                    )
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [lineColor,.clear]), startPoint: .top, endPoint: .bottom)).opacity(0.5)
                }
            }
            .chartYScale(domain: (minY)...(maxY))
            .chartXAxis(content: {
                let value = AxisMarkValues.automatic(minimumStride: 7, desiredCount: 7)
                let date = Date()
                let dayInSeconds = Double(60 * 60 * 24)
                AxisMarks(values: value, content: { value in
                    
                        switch value.index {
                        case 0:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 6))))
                        case 1:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 5))))
                        case 2:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 4))))
                        case 3:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 3))))
                        case 4:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 2))))
                        case 5:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - dayInSeconds)))
                        case 6:
                            AxisValueLabel.init(getDayOfTheWeek(date: date))
                        default:
                            AxisValueLabel.init()
                        }
                })
            })
            .frame(height:250)
            
        } else {
            Text("Charts are supported in iOS 16.0. Please update :)")
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
