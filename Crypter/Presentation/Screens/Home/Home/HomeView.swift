//
//  HomeView.swift
//  Crypter
//

import Foundation
import SwiftUI
import Combine
import UIKit

struct HomeView<ViewModel>: View where ViewModel: HomeViewModel {
    @EnvironmentObject var core: Core
    @StateObject var vm: ViewModel
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var editorCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HomeStatsView(statistics: vm.statistics)
                        .padding(.top, 8)
                    
                    SearchBarView(searchText: $vm.searchText)
                    
                    sortingHeader
                    
                    allCoinsCards
                }
                .padding()
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Market")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $editorCoin) { coin in
                HomeAddHoldingSheet(
                    vm: HomeAddHoldingViewModel(
                        coin: coin,
                        portfolioDataService: core.portfolioDataService
                    )
                )
                .environmentObject(core)
            }
            .navigationDestination(isPresented: $showDetailView) {
                if let coin = selectedCoin {
                    DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.cryptoStore))
                }
            }
            .refreshable {
                vm.reloadData()
            }
        }
    }
    
    private var sortingHeader: some View {
        HStack {
            Text("Top Cryptos")
                .font(.title3)
                .bold()
                .foregroundColor(Color.theme.textPrimary)
            
            Spacer()
            
            Menu {
                Button("Rank", action: { vm.sortOption = .rank })
                Button("Rank Reversed", action: { vm.sortOption = .rankReversed })
                Button("Highest Price", action: { vm.sortOption = .price })
                Button("Lowest Price", action: { vm.sortOption = .priceReversed })
            } label: {
                HStack(spacing: 4) {
                    Text("Sort")
                    Image(systemName: "chevron.up.chevron.down")
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.textSecondary)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color.theme.textSecondary.opacity(0.1))
                .clipShape(Capsule())
            }
        }
    }
    
    private var allCoinsCards: some View {
        VStack(spacing: 12) {
            ForEach(vm.allCoins) { coin in
                Button {
                    selectedCoin = coin
                    showDetailView = true
                } label: {
                    CoinRowView(coin: coin, showHoldingsColumn: false)
                        .padding()
                        .background(cardBackground)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        editorCoin = coin
                    } label: {
                        Label("Add to Portfolio", systemImage: "plus.circle")
                    }
                }
            }
        }
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
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(vm: PreviewHomeViewModel())
            .environmentObject(Core.preview)
    }
}

final class HomeAddHoldingViewModel: ObservableObject {
    @Published var quantityText: String = ""
    @Published private(set) var currentHoldings: Double?

    let coin: CoinModel

    private let portfolioDataService: PortfolioDataService
    private var cancellables = Set<AnyCancellable>()
    private var didLoadInitialQuantity = false

    init(coin: CoinModel, portfolioDataService: PortfolioDataService) {
        self.coin = coin
        self.portfolioDataService = portfolioDataService
        bind()
    }

    var liveValue: Double {
        guard let quantity = Double(quantityText) else { return 0 }
        return quantity * coin.currentPrice
    }

    var canSave: Bool {
        guard let amount = Double(quantityText), amount >= 0 else { return false }
        return true
    }

    var currentHoldingsText: String? {
        guard let currentHoldings, currentHoldings > 0 else { return nil }
        return "Currently holding \(currentHoldings.asNumberString()) \(coin.symbol.uppercased())"
    }

    func saveHolding() {
        guard let amount = Double(quantityText) else { return }
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }

    private func bind() {
        portfolioDataService.savedEntitiesPublisher
            .map { [weak self] entities -> Double? in
                guard let self else { return nil }
                return entities.first(where: { $0.coinID == self.coin.id })?.amount
            }
            .sink { [weak self] holdings in
                guard let self else { return }
                self.currentHoldings = holdings

                if !self.didLoadInitialQuantity {
                    self.quantityText = holdings?.asNumberString() ?? ""
                    self.didLoadInitialQuantity = true
                }
            }
            .store(in: &cancellables)
    }
}

struct HomeAddHoldingSheet: View {
    @EnvironmentObject var core: Core
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isQuantityFocused: Bool
    @StateObject var vm: HomeAddHoldingViewModel

    private var priceChangeColor: Color {
        (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.green : Color.theme.red
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    coinHeaderCard
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("7D Price Trend")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        MiniSparklineView(data: vm.coin.price ?? [])
                            .frame(height: 120)
                    }
                    
                    inputCard
                    
                    if vm.liveValue > 0 {
                        valueCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle(vm.currentHoldings == nil ? "Add Holding" : "Update Holding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(vm.currentHoldings == nil ? "Add" : "Update") {
                        saveHolding()
                    }
                    .font(.headline)
                    .disabled(!vm.canSave)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isQuantityFocused = true
                }
            }
        }
    }
}

extension HomeAddHoldingSheet {
    private var coinHeaderCard: some View {
        HStack(spacing: 16) {
            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: vm.coin))
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.coin.name)
                    .font(.headline)
                Text(vm.coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(vm.coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(vm.coin.priceChangePercentage24H?.asPercentString() ?? "0.00%")
                }
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(priceChangeColor)
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var inputCard: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Text("How much do you own?")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
                
                Spacer()
                
                TextField("Enter Amount", text: $vm.quantityText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .focused($isQuantityFocused)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isQuantityFocused && vm.quantityText.isEmpty ? Color.theme.accent.opacity(0.05) : Color.clear)
                    )
            }
            
            if let currentHoldingsText = vm.currentHoldingsText {
                Text(currentHoldingsText)
                    .font(.caption2)
                    .foregroundColor(Color.theme.green)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var valueCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Position Value")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                Text(vm.liveValue.asCurrencyWith2Decimals())
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.green)
            }
            Spacer()
        }
        .padding()
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

    private func saveHolding() {
        vm.saveHolding()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIAccessibility.post(notification: .announcement, argument: "\(vm.coin.name) saved to portfolio")
        UIApplication.shared.endEditing()
        dismiss()
    }
}
