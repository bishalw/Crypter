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
            VStack {
                
                HomeStatsView(statistics: vm.statistics)
                
                SearchBarView(searchText: $vm.searchText)
                
                ColumnTitleView(sortOption: $vm.sortOption, isPortfolioViewShown: false)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                    .padding(.horizontal)
                
                allCoinsList
                
                Spacer(minLength: 0)
            }
            .sheet(item: $editorCoin) { coin in
                HomeAddHoldingSheet(
                    vm: HomeAddHoldingViewModel(
                        coin: coin,
                        portfolioDataService: core.portfolioDataService,
                    )
                )
                .environmentObject(core)
            }
            .navigationTitle("Prices")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showDetailView) {
                if let coin = selectedCoin {
                    DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.cryptoStore))
                }
            }
        }
    }
    
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .onTapGesture {
                        selectedCoin = coin
                        showDetailView.toggle()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            editorCoin = coin
                        } label: {
                            Label("Add to Portfolio", systemImage: "plus.circle")
                        }
                        .tint(Color.theme.green)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            vm.reloadData()
        }
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
                VStack(alignment: .leading, spacing: 20) {
                    coinHeader
                    MiniSparklineView(data: vm.coin.price ?? [])
                    changeCard
                    holdingsCard
                    valueCard
                }
                .padding()
            }
            .navigationTitle(vm.currentHoldingsText == nil ? "Add Holding" : "Update Holding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .accessibilityLabel("Close add holding sheet")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Holding") {
                        saveHolding()
                    }
                    .font(.headline)
                    .disabled(!vm.canSave)
                    .accessibilityHint("Saves this coin holding to your portfolio")
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    isQuantityFocused = true
                }
            }
        }
    }
}

extension HomeAddHoldingSheet {
    private var coinHeader: some View {
        HStack(spacing: 14) {
            CoinImageView(
                vm: CoinImageViewModelImpl(
                    coinImageRepository: core.coinImageRepository,
                    coin: vm.coin
                )
            )
            .frame(width: 52, height: 52)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(vm.coin.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.theme.accent)
                Text(vm.coin.symbol.uppercased())
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Color.theme.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Current Price")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                Text(vm.coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.headline.weight(.semibold))
                    .foregroundColor(Color.theme.accent)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vm.coin.name), \(vm.coin.symbol.uppercased()), current price \(vm.coin.currentPrice.asCurrencyWith2Decimals())")
    }

    private var changeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("24H Change")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                Text(vm.coin.priceChangePercentage24H?.asPercentString() ?? "N/A")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(priceChangeColor)
            }

            Spacer()

            if let currentHoldingsText = vm.currentHoldingsText {
                Text(currentHoldingsText)
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color.theme.accent)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(14)
        .background(cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Twenty four hour change \(vm.coin.priceChangePercentage24H?.asPercentString() ?? "not available")")
    }

    private var holdingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How much do you own?")
                .font(.headline)
                .foregroundColor(Color.theme.accent)

            TextField("0.00", text: $vm.quantityText)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.title2.weight(.semibold))
                .foregroundColor(Color.theme.accent)
                .focused($isQuantityFocused)
                .accessibilityLabel("Coin amount")
                .accessibilityHint("Enter how much \(vm.coin.name) you hold")
        }
        .padding(16)
        .background(cardBackground)
    }

    private var valueCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Position Value")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                Text(vm.liveValue.asCurrencyWith2Decimals())
                    .font(.title3.weight(.semibold))
                    .foregroundColor(vm.liveValue > 0 ? Color.theme.green : Color.theme.accent)
            }

            Spacer()

            Text("7D trend")
                .font(.caption.weight(.medium))
                .foregroundColor(Color.theme.secondaryText)
        }
        .padding(14)
        .background(cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Position value \(vm.liveValue.asCurrencyWith2Decimals())")
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.theme.background)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.theme.secondaryText.opacity(0.08), lineWidth: 1)
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
