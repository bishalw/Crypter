//
//  TrendingStripView.swift
//  Crypter
//

import SwiftUI

struct TrendingStripView: View {
    let coins: [TrendingCoinModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔥 Trending on CoinGecko")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()

                Text("See all")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.brandPrimary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(coins) { coin in
                        TrendingChipView(coin: coin)
                    }
                }
            }
        }
    }
}

private struct TrendingChipView: View {
    let coin: TrendingCoinModel

    private var changeColor: Color {
        (coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    var body: some View {
        VStack(spacing: 6) {
            AsyncImage(url: URL(string: coin.imageURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else {
                    initialsBadge
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())

            Text(coin.symbol.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color.theme.textPrimary)

            if let change = coin.priceChangePercentage24H {
                Text(change.asPercentString())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(changeColor)
            }
        }
    }

    private var initialsBadge: some View {
        Circle()
            .fill(Color.theme.brandPrimary.opacity(0.25))
            .overlay(
                Text(coin.symbol.prefix(1).uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
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
