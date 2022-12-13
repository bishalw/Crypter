//
//  CoinRowView.swift
//  Crypter
//
//

import SwiftUI

struct CoinRowView: View {
    
    let coin: CoinModel
    let showHoldingsColumn: Bool // showing holdings column
    var body: some View {
        HStack(spacing: 0){
            leftColumn
            Spacer()
            if showHoldingsColumn{
                centerColumn
            }
            rightColumn
        }
        .font(.subheadline)
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
    private func createCoinImageViewModel() -> CoinImageViewModel{
        let networkManager = RealNetworkingManager.init()
        let coinImageService = CoinImageService.init(coin: coin, networkingManager: networkManager, fileManager: LocalFileManager())
        let coinImageViewModel = CoinImageViewModel.init(coin: coin, coinImageService: coinImageService)
        return coinImageViewModel
    }
    private var leftColumn: some View {
        HStack(spacing: 0){
            Text("\(coin.rank)")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .padding(.trailing)
            CoinImageView(coinImageViewModel: createCoinImageViewModel())
                .frame(width: 30, height: 30)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .padding(.leading, 6)
                .foregroundColor(Color.theme.accent)
        }
    }
    
    private var centerColumn: some View {
        VStack(alignment: .trailing){
            Text(coin.currentHoldingsValue.asCurrencyWith2Decimals())
            Text((coin.currentHoldings ?? 0).asNumberString())
        }
        .foregroundColor(Color.theme.accent)
    }
    
    private var rightColumn: some View {
        VStack(alignment: .trailing){
            Text(coin.currentPrice.asCurrencyWith6Decimals())
                .bold()
                .foregroundColor(Color.theme.accent)
            Text(coin.priceChangePercentage24H?.asPercentString() ?? "")
                .foregroundColor(
                    (coin.priceChangePercentage24H ?? 0) >= 0 ?
                    Color.theme.green :
                    Color.theme.red
                )
        }
        .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
    }
}
