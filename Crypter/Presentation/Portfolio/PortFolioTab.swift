//
//  PortFolioTab.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import Foundation
import SwiftUI
struct PortfolioTabView: View {
    @EnvironmentObject var core: Core
    @ObservedObject var vm: HomeViewModelImpl
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack {
                StatisticView(stat: StatisticModel(title: "Total Holding", value: vm.myTotalHoldingDisplayString))
                
                if vm.portfolioCoins.isEmpty {
                    Text("You haven't added any coins to your portfolio yet. Click on the + button in the Home tab to get started! 🧐")
                        .font(.callout)
                        .foregroundColor(Color.theme.accent)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(50)
                } else {
                    List {
                        ForEach(vm.portfolioCoins) { coin in
                            CoinRowView(coin: coin, showHoldingsColumn: true)
                                .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                                .onTapGesture {
                                    selectedCoin = coin
                                    showDetailView.toggle()
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationTitle("Portfolio")
        .navigationBarTitleDisplayMode(.automatic)
        .navigationDestination(isPresented: $showDetailView) {
            if let coin = selectedCoin {
                DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.getCryptoStore))
            }
        }
    }
}
