//
//  CoinLogoView.swift
//  Crypter
//
//  Created by Bishalw on 9/19/22.
//

import SwiftUI

struct CoinLogoView: View {
    
    let coin: CoinModel
    var vm: CoinImageViewModel
    
    var body: some View {
        VStack{
            CoinImageView(coinImageViewModel: vm)
                .frame(width: 50, height: 50)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .foregroundColor(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(coin.name)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
        }
    }
}

struct CoinLogoView_Previews: PreviewProvider {
    static var previews: some View {
        Text("To Do")
    }
}
