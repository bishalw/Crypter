//
//  PortFolioTab.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import Foundation
import SwiftUI

struct PortfolioView<ViewModel>: View where ViewModel: PortfolioViewModel {

    @EnvironmentObject var core: Core
    @StateObject var vm: ViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false

    var body: some View {
        NavigationStack {
            NavigationView {
                VStack(spacing: 0) {
                    statsRow

                    if vm.portfolioCoins.isEmpty {
                        emptyStateView
                    } else {
                        PortfolioAllocationChartView(
                            coins: vm.portfolioCoins,
                            totalValue: vm.totalPortfolioValue
                        )
                        .padding(.vertical, 12)

                        coinList
                    }
                }
                .navigationTitle("Portfolio")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $showDetailView) {
                    if let coin = selectedCoin {
                        DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.cryptoStore))
                    }
                }
            }
        }
    }
}

extension PortfolioView {
    private var statsRow: some View {
        HStack(spacing: 0) {
            StatisticView(stat: StatisticModel(
                title: "Portfolio Value",
                value: vm.myTotalHoldingDisplayString,
                percentageChange: vm.totalPortfolio24hChangePercent
            ))
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 40)

            StatisticView(stat: StatisticModel(
                title: "24h Change",
                value: vm.totalPortfolio24hChange >= 0
                    ? "+\(vm.totalPortfolio24hChange.asCurrencyWith2Decimals())"
                    : vm.totalPortfolio24hChange.asCurrencyWith2Decimals()
            ))
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var emptyStateView: some View {
        Text("You haven't added any coins to your portfolio yet. Click on the + button in the Home tab to get started! 🧐")
            .font(.callout)
            .foregroundColor(Color.theme.accent)
            .fontWeight(.medium)
            .multilineTextAlignment(.center)
            .padding(50)
    }

    private var coinList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .onTapGesture {
                        selectedCoin = coin
                        showDetailView.toggle()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            vm.updatePortfolio(coin: coin, amount: 0)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PortfolioView(vm: PreviewPortfolioViewModel())
                .environmentObject(Core.preview)
                .previewDisplayName("With Holdings")

            PortfolioView(vm: PreviewPortfolioViewModel(empty: true))
                .environmentObject(Core.preview)
                .previewDisplayName("Empty Portfolio")
        }
    }
}
