//
//  StatisticView.swift
//  Crypter
//
//

import SwiftUI

struct StatisticView: View {
    
    let stat: StatisticModel
    
    private var iconName: String? {
        switch stat.title {
        case "Current Price": return "dollarsign.circle"
        case "Market Capitalization": return "chart.pie"
        case "Rank": return "number"
        case "Volume": return "chart.bar"
        case "24h High": return "arrow.up.circle"
        case "24h Low": return "arrow.down.circle"
        case "24h Price Change": return "clock"
        case "24h Market Cap Change": return "chart.line.uptrend.xyaxis"
        case "Block Time": return "timer"
        case "Hashing Algorithm": return "cpu"
        case "Market Cap": return "chart.pie"
        case "Portfolio Value": return "briefcase"
        case "24h Change": return "chart.line.uptrend.xyaxis"
        default: return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(stat.title)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: 18) // Fixed height for alignment
            .foregroundColor(Color.theme.textSecondary)

            Text(stat.value)
                .font(.system(size: 17, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            if let percentageChange = stat.percentageChange {
                let isUp = percentageChange >= 0

                HStack(spacing: 4) {
                    Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 9, weight: .semibold))

                    Text((isUp ? "+" : "") + percentageChange.asPercentString())
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                }
                .foregroundColor(isUp ? Color.theme.statusSuccess : Color.theme.statusDanger)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(isUp ? Color.theme.statusSuccessSoft : Color.theme.statusDangerSoft)
                )
            }
        }
    }
}

struct StatisticView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatisticView(stat: DeveloperPreview.stat1) 
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            StatisticView(stat: dev.stat2)
                .previewLayout(.sizeThatFits)
            StatisticView(stat: dev.stat3)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}
