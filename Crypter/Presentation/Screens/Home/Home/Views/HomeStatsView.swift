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
        VStack(alignment: .leading, spacing: 14) {
            if let heroStat {
                heroSection(heroStat)
            }

            if !rowStats.isEmpty {
                Divider()
                    .overlay(Color.theme.borderSubtle)

                HStack(alignment: .top, spacing: 0) {
                    ForEach(rowStats) { stat in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(stat.title)
                                .font(.system(size: 11))
                                .foregroundColor(Color.theme.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Text(stat.value)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.theme.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.theme.surfaceBrandTint, Color.theme.surfaceSecondary],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.theme.borderSubtle, lineWidth: 1)
        )
    }

    private func heroSection(_ stat: StatisticModel) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(stat.title == "Market Cap" ? "Global market cap" : stat.title)
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)

                Text(stat.value)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 12)

            if let change = stat.percentageChange {
                changePill(change)
            }
        }
    }

    private func changePill(_ change: Double) -> some View {
        let isUp = change >= 0
        let tint = isUp ? Color.theme.statusSuccess : Color.theme.statusDanger
        let softTint = isUp ? Color.theme.statusSuccessSoft : Color.theme.statusDangerSoft
        let signedChange = (isUp ? "+" : "") + change.asPercentString()

        return HStack(spacing: 4) {
            Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 11, weight: .semibold))

            Text("\(signedChange) 24h")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
        }
        .foregroundColor(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(softTint)
        )
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
