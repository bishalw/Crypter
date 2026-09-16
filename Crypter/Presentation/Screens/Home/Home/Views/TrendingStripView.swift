//
//  TrendingStripView.swift
//  Crypter
//

import SwiftUI

struct TrendingStripView: View {
    let coins: [TrendingCoinModel]
    var onSelect: ((TrendingCoinModel) -> Void)? = nil
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 14))

                Text("Trending on CoinGecko")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer(minLength: 8)

                if let onSeeAll {
                    Button("See all", action: onSeeAll)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.theme.brandPrimary)
                        .buttonStyle(.plain)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(coins) { coin in
                        Button {
                            onSelect?(coin)
                        } label: {
                            TrendingCardView(coin: coin)
                        }
                        .buttonStyle(.plain)
                        .disabled(onSelect == nil)
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


/// The strip only shows the first few; this lists all of CoinGecko's trending
/// coins, and hands the chosen one back to Markets to look up.
struct TrendingListSheet: View {
    let coins: [TrendingCoinModel]
    let onSelect: (TrendingCoinModel) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(coins.enumerated()), id: \.element.id) { index, coin in
                    Button {
                        onSelect(coin)
                        dismiss()
                    } label: {
                        row(index: index, coin: coin)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.theme.surfaceBackground)
                    .listRowSeparatorTint(Color.theme.borderSubtle)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Trending")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.theme.brandPrimary)
                }
            }
        }
    }

    private func row(index: Int, coin: TrendingCoinModel) -> some View {
        let change = coin.priceChangePercentage24H

        return HStack(spacing: 12) {
            Text("\(index + 1)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.theme.textTertiary)
                .frame(width: 16, alignment: .leading)

            AsyncImage(url: URL(string: coin.imageURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else {
                    Circle().fill(Color.theme.brandSoft)
                }
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(coin.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                Text(coin.symbol.uppercased())
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)
            }

            Spacer(minLength: 8)

            Text(change.map { ($0 >= 0 ? "+" : "") + $0.asPercentString() } ?? "—")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor((change ?? 0) >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
