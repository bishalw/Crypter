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
    @State private var showPortfolioEditor: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if vm.portfolioCoins.isEmpty {
                    emptyStateView
                } else {
                    statsRow

                    PortfolioAllocationChartView(
                        coins: vm.portfolioCoins,
                        totalValue: vm.totalPortfolioValue
                    )
                    .padding(.bottom, 8)

                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 8)

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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPortfolioEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                    .accessibilityLabel("Add coin to portfolio")
                }
            }
            .sheet(isPresented: $showPortfolioEditor) {
                PortfolioEditorView(
                    vm: PortfolioEditorViewModel(
                        cryptoStore: core.cryptoStore,
                        portfolioDataService: core.portfolioDataService
                    )
                )
                .environmentObject(core)
            }
            .refreshable {
                vm.reloadData()
            }
        }
    }
}

extension PortfolioView {
    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Portfolio Value",
                value: vm.myTotalHoldingDisplayString,
                percentageChange: vm.totalPortfolio24hChangePercent
            )

            statCard(
                title: "24h Change",
                value: vm.totalPortfolio24hChange >= 0
                    ? "+\(vm.totalPortfolio24hChange.asCurrencyWith2Decimals())"
                    : vm.totalPortfolio24hChange.asCurrencyWith2Decimals(),
                percentageChange: nil
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private func statCard(title: String, value: String, percentageChange: Double?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)

            Text(value)
                .font(.headline)
                .foregroundColor(Color.theme.accent)

            if let change = percentageChange {
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.caption2)
                        .rotationEffect(Angle(degrees: change >= 0 ? 0 : 180))
                    Text(change.asPercentString())
                        .font(.caption)
                        .bold()
                }
                .foregroundColor(change >= 0 ? Color.theme.green : Color.theme.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.theme.background.opacity(0.5))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 60))
                .foregroundColor(Color.theme.accent.opacity(0.4))

            Text("Build Your Portfolio")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.accent)

            Text("Add your first coin to start tracking your portfolio value and allocation.")
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                showPortfolioEditor = true
            } label: {
                Text("Add Your First Coin")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)
            .accessibilityHint("Opens the portfolio editor to add a new coin")
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Build Your Portfolio. Add your first coin to start tracking your portfolio value and allocation.")
    }

    private var coinList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .listRowBackground(Color.clear)
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
