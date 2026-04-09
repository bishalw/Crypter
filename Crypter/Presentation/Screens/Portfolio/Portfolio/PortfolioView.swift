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
            ZStack {
                // Keep background color consistent
                Color.theme.background.ignoresSafeArea()
                
                if vm.portfolioCoins.isEmpty {
                    emptyStateView
                } else {
                    portfolioContent
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large) // Large title feels more like a dashboard
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
                        // Improved toolbar button design
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color.theme.accent)
                    }
                    .accessibilityLabel("Add coin to portfolio")
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
    
    // MARK: - Stats Section
    private var statsRow: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Portfolio Value",
                value: vm.myTotalHoldingDisplayString,
                percentageChange: vm.totalPortfolio24hChangePercent
            )

            statCard(
                title: "24h Change",
                value: vm.totalPortfolio24hChange.asSignedCompactCurrency(),
                percentageChange: nil
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func statCard(title: String, value: String, percentageChange: Double?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(Color.theme.secondaryText)
                .textCase(.uppercase) // Adds a subtle dashboard feel

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(Color.theme.accent)
                .minimumScaleFactor(0.7)
                .monospacedDigit()

            if let change = percentageChange {
                HStack(spacing: 4) {
                    Image(systemName: "triangle.fill")
                        .font(.system(size: 8))
                        .rotationEffect(Angle(degrees: change >= 0 ? 0 : 180))
                    Text(change.asPercentString())
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                }
                .foregroundColor(change >= 0 ? Color.theme.green : Color.theme.red)
            } else {
                // Placeholder to keep cards the exact same height
                Text(" ")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        // Upgraded the card background to use materials instead of flat colors
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.theme.accent.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.bottom, 8)

            Text("Build Your Portfolio")
                .font(.title2.weight(.bold))
                .foregroundColor(Color.theme.accent)

            Text("Add your first coin to start tracking your portfolio value and allocation.")
                .font(.callout)
                .foregroundColor(Color.theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                showPortfolioEditor = true
            } label: {
                Text("Add First Coin")
                    .font(.headline)
                    // Used system background so it contrasts against the accent color perfectly in both light/dark modes
                    .foregroundColor(Color.theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Main Content
    private var portfolioContent: some View {
        List {
            // Grouping Stats and Chart into a single section with no row separators
            Section {
                statsRow
                    .listRowInsets(EdgeInsets()) // Removed all default list padding
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                PortfolioAllocationChartView(
                    coins: vm.portfolioCoins,
                    totalValue: vm.totalPortfolioValue,
                    totalChange: vm.totalPortfolio24hChange
                )
                .padding(.horizontal, 16) // Handle padding manually
                .padding(.bottom, 16)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            // Assets Section
            Section {
                HStack {
                    Text("Your Assets")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                    
                    Spacer()
                    
                    Menu {
                        Button("Highest Holdings", action: { vm.sortOption = .holdings })
                        Button("Lowest Holdings", action: { vm.sortOption = .holdingsReversed })
                        Button("Highest Price", action: { vm.sortOption = .price })
                        Button("Lowest Price", action: { vm.sortOption = .priceReversed })
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                }
                ForEach(vm.portfolioCoins) { coin in
                    CoinRowView(coin: coin, showHoldingsColumn: true)
                        .padding(.vertical, 4) // Slight vertical breathing room
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.visible) // Keep separator for list items only
                        .listRowSeparatorTint(Color.theme.secondaryText.opacity(0.3))
                        .contentShape(Rectangle()) // Ensures entire row is tappable
                        .onTapGesture {
                            selectedCoin = coin
                            showDetailView = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation { vm.updatePortfolio(coin: coin, amount: 0) }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden) // Cleaner look for dashboards
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
