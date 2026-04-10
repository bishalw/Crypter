//
//  PortFolioTab.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import Foundation
import SwiftUI

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
            ScrollView {
                VStack(spacing: 24) {
                    if vm.portfolioCoins.isEmpty {
                        emptyStateView
                            .padding(.top, 60)
                    } else {
                        portfolioHeader
                        
                        PortfolioAllocationChartView(
                            coins: vm.portfolioCoins,
                            totalValue: vm.totalPortfolioValue,
                            totalChange: vm.totalPortfolio24hChange
                        )
                        
                        assetListHeader
                        
                        assetCards
                    }
                }
                .padding()
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
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
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color.theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showPortfolioEditor) {
                PortfolioEditorView(vm: PortfolioEditorViewModel(cryptoStore: core.cryptoStore, portfolioDataService: core.portfolioDataService))
                    .environmentObject(core)
            }
            .refreshable {
                vm.reloadData()
            }
        }
    }
}

extension PortfolioView {
    
    private var portfolioHeader: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Portfolio Value",
                value: vm.myTotalHoldingDisplayString,
                percentageChange: vm.totalPortfolio24hChangePercent,
                icon: "briefcase.fill"
            )

            statCard(
                title: "24h Change",
                value: vm.totalPortfolio24hChange.asSignedCompactCurrency(),
                percentageChange: nil,
                icon: "chart.line.uptrend.xyaxis"
            )
        }
    }

    private func statCard(title: String, value: String, percentageChange: Double?, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
            }
            .foregroundColor(Color.theme.secondaryText)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.accent)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                if let change = percentageChange {
                    HStack(spacing: 4) {
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 8))
                            .rotationEffect(Angle(degrees: change >= 0 ? 0 : 180))
                        Text(change.asPercentString())
                            .font(.caption2)
                            .bold()
                    }
                    .foregroundColor(change >= 0 ? Color.theme.green : Color.theme.red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.theme.surfaceSecondary)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.theme.borderSubtle, lineWidth: 1)
            )
    }

    private var assetListHeader: some View {
        HStack {
            Text("Your Assets")
                .font(.title3)
                .bold()
                .foregroundColor(Color.theme.accent)
            
            Spacer()
            
            Menu {
                Button("Highest Holdings", action: { vm.sortOption = .holdings })
                Button("Lowest Holdings", action: { vm.sortOption = .holdingsReversed })
                Button("Highest Price", action: { vm.sortOption = .price })
                Button("Lowest Price", action: { vm.sortOption = .priceReversed })
            } label: {
                HStack(spacing: 4) {
                    Text("Sort")
                    Image(systemName: "chevron.up.chevron.down")
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.secondaryText)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.theme.secondaryText.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }

    private var assetCards: some View {
        VStack(spacing: 12) {
            ForEach(vm.portfolioCoins) { coin in
                Button {
                    selectedCoin = coin
                    showDetailView = true
                } label: {
                    CoinRowView(coin: coin, showHoldingsColumn: true)
                        .padding()
                        .background(cardBackground)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) {
                        withAnimation { vm.updatePortfolio(coin: coin, amount: 0) }
                    } label: {
                        Label("Remove from Portfolio", systemImage: "trash")
                    }
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.theme.accent.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.theme.accent)
            }

            VStack(spacing: 8) {
                Text("Build Your Portfolio")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.theme.accent)

                Text("Start tracking your crypto assets by adding your first coin.")
                    .font(.callout)
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                showPortfolioEditor = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add First Coin")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
        }
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
