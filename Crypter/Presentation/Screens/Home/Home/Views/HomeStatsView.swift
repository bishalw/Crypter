//
//  HomeStatsView.swift
//  Crypter
//
//

import SwiftUI

struct HomeStatsView: View {

    var statistics: [StatisticModel]

    private var heroStat: StatisticModel? { statistics.first }
    private var rowStats: [StatisticModel] { Array(statistics.dropFirst()) }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let heroStat {
                heroSection(heroStat)
            }

            if !rowStats.isEmpty {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(rowStats) { stat in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stat.title)
                                .font(.caption2)
                                .foregroundColor(Color.theme.textSecondary)
                            Text(stat.value)
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.theme.borderSubtle, lineWidth: 1)
                )
        )
    }

    private func heroSection(_ stat: StatisticModel) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(stat.title == "Market Cap" ? "Global market cap" : stat.title)
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
                Text(stat.value)
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.textPrimary)
            }

            Spacer()

            if let change = stat.percentageChange {
                HStack(spacing: 4) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(change.asPercentString()) 24h")
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(change >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill((change >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger).opacity(0.15))
                )
            }
        }
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(statistics: [
            StatisticModel(title: "Market Cap", value: "$3.94T", percentageChange: 1.82),
            StatisticModel(title: "24h Volume", value: "$142.6B"),
            StatisticModel(title: "BTC Dominance", value: "57.2%"),
            StatisticModel(title: "ETH Dominance", value: "13.1%")
        ])
        .padding()
        .background(Color.theme.surfaceBackground)
        .preferredColorScheme(.dark)
    }
}
