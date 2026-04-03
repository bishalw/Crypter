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
        HStack(spacing: 12) {
            leftColumn
            if showHoldingsColumn {
                centerColumn
            }
            rightColumn
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.background.opacity(0.001))
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
        HStack(spacing: 8) {
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .frame(minWidth: 28, alignment: .leading)

            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: CoinImageRepositoryImpl(networkingManager: core.networkingManager, localFileManager: core.localFileManager), coin: coin))
                .frame(width: 30, height: 30)

            Text(coin.symbol.uppercased())
                .font(.headline)
                .foregroundColor(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .layoutPriority(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var centerColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(holdingsValueText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .monospacedDigit()
            Text(holdingsAmountText)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .monospacedDigit()
        }
        .foregroundColor(Color.theme.accent)
        .frame(width: 108, alignment: .trailing)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var rightColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(priceText)
                .bold()
                .foregroundColor(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .monospacedDigit()
            Text(percentChangeText)
                .font(.caption)
                .foregroundColor(
                    (coin.priceChangePercentage24H ?? 0) >= 0 ?
                    Color.theme.green :
                    Color.theme.red
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .monospacedDigit()
        }
        .frame(width: showHoldingsColumn ? 104 : 118, alignment: .trailing)
        .fixedSize(horizontal: false, vertical: true)
    }
}
