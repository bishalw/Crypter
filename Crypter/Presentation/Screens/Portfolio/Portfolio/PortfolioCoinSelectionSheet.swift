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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(searchText: $vm.searchText)

                if let coin = selectedCoin {
                    selectedCoinDetail(coin: coin)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                coinList
                Spacer(minLength: 0)
            }
            .navigationTitle(selectedCoin == nil ? "Manage Portfolio" : "Edit Holding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .accessibilityLabel("Close portfolio editor")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveButtonPressed()
                    }
                    .font(.headline)
                    .disabled(!canSave)
                    .accessibilityHint("Saves the selected coin amount to your portfolio")
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
        List(vm.allCoins) { coin in
            coinRow(coin: coin)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectCoin(coin)
                    }
                }
                .listRowBackground(
                    selectedCoin?.id == coin.id
                        ? Color.theme.green.opacity(0.1)
                        : Color.clear
                )
        }
        .listStyle(.plain)
    }

    private func coinRow(coin: CoinModel) -> some View {
        let holdings = coin.currentHoldings ?? 0

        return HStack(spacing: 12) {
            CoinImageView(
                vm: CoinImageViewModelImpl(
                    coinImageRepository: core.coinImageRepository,
                    coin: coin
                )
            )
            .frame(width: 36, height: 36)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(coin.symbol.uppercased())
                    .font(.headline)
                Text(coin.name)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.subheadline.bold())

                if holdings > 0 {
                    Text("\(holdings.asNumberString()) held")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }

            if selectedCoin?.id == coin.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.theme.green)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(coin.name), \(coin.symbol.uppercased()), price \(coin.currentPrice.asCurrencyWith2Decimals())")
        .accessibilityValue(holdings > 0 ? "\(holdings.asNumberString()) currently held" : "Not in portfolio")
        .accessibilityHint("Select to edit the amount in your portfolio")
    }
}

// MARK: - Selected Coin Detail

extension PortfolioEditorView {
    private func selectedCoinDetail(coin: CoinModel) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                CoinImageView(
                    vm: CoinImageViewModelImpl(
                        coinImageRepository: core.coinImageRepository,
                        coin: coin
                    )
                )
                .id(coin.id)
                .frame(width: 32, height: 32)
                .clipShape(Circle())

                Text(coin.symbol.uppercased())
                    .font(.headline)

                Spacer()

                Text(coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            HStack {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
                Spacer()
                TextField("0.00", text: $quantityText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.title3.bold())
                    .frame(maxWidth: 150)
                    .accessibilityLabel("Coin amount")
                    .accessibilityHint("Enter how much \(coin.name) you hold using a decimal number")
            }
            .padding(.horizontal)
            .padding(.top, 12)

            HStack {
                Text("Value")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.secondaryText)
                Spacer()
                Text(currentValue.asCurrencyWith2Decimals())
                    .font(.subheadline.bold())
                    .foregroundColor(currentValue > 0 ? Color.theme.green : Color.theme.secondaryText)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Divider()
        }
        .background(Color.theme.background)
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

        if let holdings = vm.currentHoldings(for: coin) {
            quantityText = holdings.asNumberString()
        } else {
            quantityText = ""
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
