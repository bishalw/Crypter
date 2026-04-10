//
//  PortfolioCoinSelectionSheet.swift
//  Crypter
//

import SwiftUI
import Combine
import UIKit

final class PortfolioEditorViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var allCoins: [CoinModel] = []

    let preselectedCoinID: String?

    private let cryptoStore: CryptoStore
    private let portfolioDataService: PortfolioDataService
    private var cancellables = Set<AnyCancellable>()
    private var holdingsByCoinID: [String: Double] = [:]

    init(
        cryptoStore: CryptoStore,
        portfolioDataService: PortfolioDataService,
        preselectedCoinID: String? = nil
    ) {
        self.cryptoStore = cryptoStore
        self.portfolioDataService = portfolioDataService
        self.preselectedCoinID = preselectedCoinID

        bind()
        cryptoStore.fetchAllCoins()
    }

    func currentHoldings(for coin: CoinModel) -> Double? {
        holdingsByCoinID[coin.id]
    }

    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }

    func coin(withID id: String) -> CoinModel? {
        guard let coin = allCoins.first(where: { $0.id == id }) else {
            return nil
        }

        if let holdings = holdingsByCoinID[id] {
            return coin.updateHoldings(amount: holdings)
        }

        return coin
    }

    private func bind() {
        Publishers.CombineLatest3($searchText, cryptoStore.coins, portfolioDataService.savedEntitiesPublisher)
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .map { [weak self] searchText, allCoins, portfolioEntities in
                self?.mapCoins(
                    searchText: searchText,
                    allCoins: allCoins ?? [],
                    portfolioEntities: portfolioEntities
                ) ?? []
            }
            .sink { [weak self] mappedCoins in
                self?.allCoins = mappedCoins
            }
            .store(in: &cancellables)
    }

    private func mapCoins(searchText: String, allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
        holdingsByCoinID = Dictionary(
            uniqueKeysWithValues: portfolioEntities.compactMap { entity in
                guard let coinID = entity.coinID else {
                    return nil
                }

                return (coinID, entity.amount)
            }
        )

        let coinsWithHoldings = allCoins.map { coin -> CoinModel in
            guard let holdings = holdingsByCoinID[coin.id] else {
                return coin
            }

            return coin.updateHoldings(amount: holdings)
        }

        guard !searchText.isEmpty else {
            return coinsWithHoldings
        }

        let lowercasedText = searchText.lowercased()
        return coinsWithHoldings.filter { coin in
            coin.name.lowercased().contains(lowercasedText) ||
            coin.symbol.lowercased().contains(lowercasedText) ||
            coin.id.lowercased().contains(lowercasedText)
        }
    }
}

struct PortfolioEditorView: View {
    @EnvironmentObject var core: Core
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: PortfolioEditorViewModel

    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText: String = ""
    @State private var didApplyInitialSelection = false
    @FocusState private var isQuantityFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(searchText: $vm.searchText)

                if let coin = selectedCoin {
                    selectedCoinDetail(coin: coin)
                        .padding()
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }

                coinList
                Spacer(minLength: 0)
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle(selectedCoin == nil ? "Manage Portfolio" : (vm.currentHoldings(for: selectedCoin!) == nil ? "Add \(selectedCoin?.symbol.uppercased() ?? "")" : "Update \(selectedCoin?.symbol.uppercased() ?? "")"))
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
                    let buttonTitle: String = {
                        guard let coin = selectedCoin else { return "Save" }
                        return vm.currentHoldings(for: coin) == nil ? "Add" : "Update"
                    }()
                    
                    Button(buttonTitle) {
                        saveButtonPressed()
                    }
                    .font(.headline)
                    .disabled(!canSave)
                    .opacity(selectedCoin == nil ? 0 : 1)
                }
            }
            .onAppear {
                selectInitialCoinIfNeeded()
            }
            .onReceive(vm.$allCoins) { _ in
                selectInitialCoinIfNeeded()
            }
        }
    }
}

// MARK: - Coin List

extension PortfolioEditorView {
    private var coinList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.allCoins) { coin in
                    coinRow(coin: coin)
                        .padding(.horizontal)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectCoin(coin)
                            }
                        }
                }
            }
            .padding(.top)
        }
    }

    private func coinRow(coin: CoinModel) -> some View {
        let isSelected = selectedCoin?.id == coin.id
        let holdings = coin.currentHoldings ?? 0

        return HStack(spacing: 12) {
            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: coin))
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.symbol.uppercased())
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
                Text(coin.name)
                    .font(.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color.theme.textPrimary)

                if holdings > 0 {
                    Text("\(holdings.asNumberString()) held")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.statusSuccess)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
                .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.05), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? Color.theme.brandPrimary.opacity(0.5) : Color.theme.borderSubtle, lineWidth: 1)
        )
        .scaleEffect(isSelected ? 0.98 : 1.0)
    }
}

// MARK: - Selected Coin Detail

extension PortfolioEditorView {
    private func selectedCoinDetail(coin: CoinModel) -> some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: coin))
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    Text(coin.name)
                        .font(.headline)
                        .foregroundColor(Color.theme.textPrimary)
                }
                
                Spacer()
                
                Text(coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(Color.theme.textSecondary)
            }

            Divider()
                .overlay(Color.theme.borderSubtle)

            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Text("Holdings")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.textSecondary)
                    Spacer()
                    TextField("Enter Amount", text: $quantityText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.textPrimary)
                        .focused($isQuantityFocused)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isQuantityFocused && quantityText.isEmpty ? Color.theme.brandPrimary.opacity(0.1) : Color.clear)
                        )
                }
                
                if quantityText.isEmpty {
                    Text("How much \(coin.symbol.uppercased()) do you own?")
                        .font(.caption2)
                        .foregroundColor(Color.theme.brandPrimary)
                        .transition(.opacity)
                }
            }

            HStack {
                Text("Total Value")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
                Spacer()
                Text(currentValue.asCurrencyWith2Decimals())
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(currentValue > 0 ? Color.theme.statusSuccess : Color.theme.textPrimary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.theme.surfaceSecondary)
                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.theme.brandPrimary.opacity(0.3), lineWidth: 1)
        )
    }

    private var currentValue: Double {
        guard let quantity = Double(quantityText),
              let selectedCoin = selectedCoin else {
            return 0
        }

        return quantity * selectedCoin.currentPrice
    }
}

// MARK: - Actions

extension PortfolioEditorView {
    private var canSave: Bool {
        guard selectedCoin != nil,
              let amount = Double(quantityText),
              amount >= 0 else {
            return false
        }

        return true
    }

    private func selectCoin(_ coin: CoinModel) {
        selectedCoin = coin
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if let holdings = vm.currentHoldings(for: coin) {
            quantityText = holdings.asNumberString()
        } else {
            quantityText = ""
        }
        
        // Short delay to ensure view is rendered before focusing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isQuantityFocused = true
        }
    }

    private func selectInitialCoinIfNeeded() {
        guard !didApplyInitialSelection,
              let preselectedCoinID = vm.preselectedCoinID,
              let coin = vm.coin(withID: preselectedCoinID) else {
            return
        }

        didApplyInitialSelection = true
        selectCoin(coin)
    }

    private func saveButtonPressed() {
        guard let coin = selectedCoin,
              let amount = Double(quantityText) else {
            return
        }

        vm.updatePortfolio(coin: coin, amount: amount)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIAccessibility.post(notification: .announcement, argument: "\(coin.name) saved to portfolio")
        UIApplication.shared.endEditing()
        dismiss()
    }
}

struct PortfolioEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioEditorView(
            vm: PortfolioEditorViewModel(
                cryptoStore: MockCryptoStore(),
                portfolioDataService: PortfolioDataServiceImpl()
            )
        )
        .environmentObject(Core.preview)
    }
}
