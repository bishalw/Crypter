//
//  TrendingStripView.swift
//  Crypter
//

import SwiftUI

struct TrendingStripView: View {
    let coins: [TrendingCoinModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 14))

                Text("Trending on CoinGecko")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer(minLength: 8)

                Text("See all")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.theme.brandPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(coins) { coin in
                        TrendingCardView(coin: coin)
                    }
                }
            }
        }
    }
}

private struct TrendingCardView: View {
    let coin: TrendingCoinModel

    private var isUp: Bool { (coin.priceChangePercentage24H ?? 0) >= 0 }

    private var changeColor: Color {
        isUp ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var changeText: String {
        guard let change = coin.priceChangePercentage24H else { return "—" }
        return (change >= 0 ? "+" : "") + change.asPercentString()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: coin.imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit()
                    } else {
                        initialsBadge
                    }
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())

                Text(coin.symbol.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
            }

            Text(changeText)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundColor(changeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(width: 112, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.theme.borderSubtle, lineWidth: 1)
        )
    }

    private var initialsBadge: some View {
        Circle()
            .fill(Color.theme.brandSoft)
            .overlay(
                Text(coin.symbol.prefix(1).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.theme.brandPrimary)
            )
    }
}

struct TrendingStripView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingStripView(coins: TrendingCoinModel.mockTrendingCoins())
            .padding()
            .background(Color.theme.surfaceBackground)
            .preferredColorScheme(.dark)
    }
}
