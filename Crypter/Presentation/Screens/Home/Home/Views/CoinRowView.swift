//
//  CoinRowView.swift
//  Crypter
//


import SwiftUI

struct CoinRowView: View {
    @EnvironmentObject var core: Core
    let coin: CoinModel
    let showHoldingsColumn: Bool

    private var holdingsValueText: String {
        coin.currentHoldingsValue.asCompactCurrency()
    }

    private var holdingsAmountText: String {
        (coin.currentHoldings ?? 0).asNumberString()
    }

    private var priceText: String {
        coin.currentPrice >= 1000
            ? coin.currentPrice.asCurrencyWith2Decimals()
            : coin.currentPrice.asCurrencyWith6Decimals()
    }

    private var percentChangeText: String {
        coin.priceChangePercentage24H?.asPercentString() ?? ""
    }

    var body: some View {
        HStack(spacing: 0) {
            leftColumn
            
            if showHoldingsColumn {
                centerColumn
                    .padding(.horizontal, 8)
            }
            
            rightColumn
        }
        .background(Color.theme.surfaceBackground.opacity(0.001))
    }
}

struct CoinRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            CoinRowView(coin: dev.coin, showHoldingsColumn: true)
                .previewLayout(.sizeThatFits)
        }
            CoinRowView(coin: dev.coin, showHoldingsColumn: true)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
extension CoinRowView {
    private var leftColumn: some View {
        HStack(spacing: 12) {
            Text("\(coin.rank)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color.theme.textSecondary)
                .frame(width: 20, alignment: .leading)

            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: coin))
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.symbol.uppercased())
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.textPrimary)
                Text(coin.name)
                    .font(.system(size: 11))
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var centerColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(holdingsValueText)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.theme.textPrimary)
            Text(holdingsAmountText)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(minWidth: 80, alignment: .trailing)
    }
    
    private var rightColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(priceText)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Color.theme.textPrimary)
            
            HStack(spacing: 4) {
                Image(systemName: (coin.priceChangePercentage24H ?? 0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text(percentChangeText)
            }
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(
                (coin.priceChangePercentage24H ?? 0) >= 0 ?
                Color.theme.statusSuccess :
                Color.theme.statusDanger
            )
        }
        .frame(minWidth: 90, alignment: .trailing)
    }
}
