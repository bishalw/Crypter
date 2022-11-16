//
//  DetailView.swift
//  Crypter
//
//  Created by Bishalw on 11/14/22.
//

import SwiftUI

struct DetailView: View {
    let coin: CoinModel
    
    var body: some View {
        Text(coin.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(coin: dev.coin)
    }
}
