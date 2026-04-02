//
//  PortfolioCoinSelectionSheet.swift
//  Crypter
//

import SwiftUI

struct PortfolioCoinSelectionSheet<ViewModel>: View where ViewModel: HomeViewModel {
    @EnvironmentObject var core: Core
    @StateObject var vm: ViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText: String = ""
    @State private var showCheckmark: Bool = false
    @Environment(\.dismiss) var dismiss

    private var displayedCoins: [CoinModel] {
        vm.searchText.isEmpty ? vm.portfolioCoins : vm.allCoins
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBarView(searchText: $vm.searchText)

                if let coin = selectedCoin {
                    selectedCoinDetail(coin: coin)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                coinList

                Spacer(minLength: 0)
            }
            .navigationTitle("Edit Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveToolbarContent
                }
            }
            .onChange(of: vm.searchText) { value in
                if value.isEmpty {
                    clearSelection()
                }
            }
        }
    }
}

// MARK: - Coin List

extension PortfolioCoinSelectionSheet {

    private var coinList: some View {
        List(displayedCoins) { coin in
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
        HStack(spacing: 12) {
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

                if let holdings = coin.currentHoldings, holdings > 0 {
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
    }
}

// MARK: - Selected Coin Detail

extension PortfolioCoinSelectionSheet {

    private func selectedCoinDetail(coin: CoinModel) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                CoinImageView(
                    vm: CoinImageViewModelImpl(
                        coinImageRepository: core.coinImageRepository,
                        coin: coin
                    )
                )
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

            // Input row
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
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Value row
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
        guard let quantity = Double(quantityText) else { return 0 }
        return quantity * (selectedCoin?.currentPrice ?? 0)
    }
}

// MARK: - Toolbar & Actions

extension PortfolioCoinSelectionSheet {

    @ViewBuilder
    private var saveToolbarContent: some View {
        if showCheckmark {
            Image(systemName: "checkmark")
                .foregroundColor(Color.theme.green)
                .font(.headline)
        } else if canSave {
            Button {
                saveButtonPressed()
            } label: {
                Text("SAVE")
                    .font(.headline)
            }
        }
    }

    private var canSave: Bool {
        guard let coin = selectedCoin else { return false }
        return coin.currentHoldings != Double(quantityText)
    }

    private func selectCoin(_ coin: CoinModel) {
        selectedCoin = coin
        if let holdings = vm.portfolioCoins.first(where: { $0.id == coin.id })?.currentHoldings {
            quantityText = "\(holdings)"
        } else {
            quantityText = ""
        }
    }

    private func saveButtonPressed() {
        guard let coin = selectedCoin,
              let amount = Double(quantityText)
        else { return }

        vm.updatePortfolio(coin: coin, amount: amount)

        withAnimation(.easeIn) {
            showCheckmark = true
            clearSelection()
        }

        UIApplication.shared.endEditing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut) {
                showCheckmark = false
            }
        }
    }

    private func clearSelection() {
        selectedCoin = nil
        quantityText = ""
        vm.searchText = ""
    }
}

struct PortfolioCoinSelectionSheet_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioCoinSelectionSheet(vm: PreviewHomeViewModel())
            .environmentObject(Core.preview)
    }
}
