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

    func addTransaction(coin: CoinModel, kind: TransactionKind, amount: Double, pricePerCoin: Double, date: Date) {
        portfolioDataService.addTransaction(
            coin: coin,
            kind: kind,
            amount: amount,
            pricePerCoin: pricePerCoin,
            date: date
        )
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
            .map { [weak self] searchText, allCoins, holdings in
                self?.mapCoins(
                    searchText: searchText,
                    allCoins: allCoins ?? [],
                    holdings: holdings
                ) ?? []
            }
            .sink { [weak self] mappedCoins in
                self?.allCoins = mappedCoins
            }
            .store(in: &cancellables)
    }

    private func mapCoins(searchText: String, allCoins: [CoinModel], holdings: [PortfolioHolding]) -> [CoinModel] {
        holdingsByCoinID = Dictionary(
            uniqueKeysWithValues: holdings.map { ($0.coinID, $0.amount) }
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
    @State private var priceText: String = ""
    @State private var transactionKind: TransactionKind = .buy
    @State private var transactionDate: Date = Date()
    @FocusState private var isPriceFocused: Bool
    @State private var didApplyInitialSelection = false
    @FocusState private var isQuantityFocused: Bool

    private enum Metrics {
        static let horizontalInset: CGFloat = 20
        static let rowPadding: CGFloat = 12
        static let avatarSize: CGFloat = 36
        static let rowSpacing: CGFloat = 12
        static let checkSlot: CGFloat = 18
        static let rowCornerRadius: CGFloat = 14
        static let panelCornerRadius: CGFloat = 18
    }

    var body: some View {
        NavigationStack {
            List {
                if let coin = selectedCoin {
                    selectedCoinPanel(coin: coin)
                        .listRowInsets(EdgeInsets(
                            top: 8,
                            leading: Metrics.horizontalInset,
                            bottom: 12,
                            trailing: Metrics.horizontalInset
                        ))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                Section {
                    ForEach(vm.allCoins) { coin in
                        coinRow(coin: coin)
                    }
                } header: {
                    listHeader
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 0)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(Color.theme.surfaceBackground)
            .searchable(
                text: $vm.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: Text("Search coins")
            )
            .minimizedSearchToolbarIfAvailable()
            .autocorrectionDisabled()
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.theme.surfaceBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveButtonPressed()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.theme.brandPrimary)
                    .disabled(!canSave)
                }

            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
            }
            .onAppear {
                selectInitialCoinIfNeeded()
            }
            .onReceive(vm.$allCoins) { _ in
                selectInitialCoinIfNeeded()
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var navigationTitle: String {
        transactionKind == .sell ? "Sell" : "Add transaction"
    }
}

// MARK: - Coin List

extension PortfolioEditorView {
    private var listHeader: some View {
        HStack {
            Text("All coins")
            Spacer(minLength: 8)
            Text("Tap to select")
        }
        .font(.system(size: 11))
        .foregroundStyle(Color.theme.textTertiary)
        .textCase(nil)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: Metrics.horizontalInset,
            bottom: 0,
            trailing: Metrics.horizontalInset
        ))
        .listRowBackground(Color.theme.surfaceBackground)
        .listRowSeparator(.hidden)
    }

    private func coinRow(coin: CoinModel) -> some View {
        let isSelected = selectedCoin?.id == coin.id
        let holdings = coin.currentHoldings ?? 0

        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                selectCoin(coin)
            }
        } label: {
            HStack(spacing: Metrics.rowSpacing) {
                coinAvatar(coin: coin, size: Metrics.avatarSize)

                VStack(alignment: .leading, spacing: 3) {
                    Text(coin.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text(coin.symbol.uppercased())
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .lineLimit(1)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(coin.currentPrice.asCurrencyWith6Decimals())
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(Color.theme.textPrimary)

                    if holdings > 0 {
                        Text("\(Self.heldAmountString(holdings)) held")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.theme.textTertiary)
                    }
                }
                .lineLimit(1)

                ZStack {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.theme.brandPrimary)
                    }
                }
                .frame(width: Metrics.checkSlot, height: Metrics.checkSlot)
            }
            .padding(Metrics.rowPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(
            top: 1,
            leading: Metrics.horizontalInset,
            bottom: 1,
            trailing: Metrics.horizontalInset
        ))
        .listRowBackground(rowBackground(isSelected: isSelected))
        .listRowSeparator(isSelected ? .hidden : .visible)
        .listRowSeparatorTint(Color.theme.borderSubtle)
        .alignmentGuide(.listRowSeparatorLeading) { _ in
            Metrics.rowPadding + Metrics.avatarSize + Metrics.rowSpacing
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    @ViewBuilder
    private func rowBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: Metrics.rowCornerRadius, style: .continuous)
                .fill(Color.theme.brandSoft)
                .overlay(
                    RoundedRectangle(cornerRadius: Metrics.rowCornerRadius, style: .continuous)
                        .strokeBorder(Color.theme.brandPrimary, lineWidth: 1)
                )
                .padding(.horizontal, Metrics.horizontalInset)
        } else {
            Color.theme.surfaceBackground
        }
    }

    private func coinAvatar(coin: CoinModel, size: CGFloat) -> some View {
        CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: coin))
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

// MARK: - Selected Coin Panel

extension PortfolioEditorView {
    private func selectedCoinPanel(coin: CoinModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                coinAvatar(coin: coin, size: Metrics.avatarSize)

                VStack(alignment: .leading, spacing: 3) {
                    Text(coin.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.theme.textPrimary)
                    Text("\(coin.symbol.uppercased()) · \(coin.currentPrice.asCurrencyWith6Decimals())")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .lineLimit(1)

                Spacer(minLength: 8)

                if vm.currentHoldings(for: coin) != nil {
                    Text("In portfolio")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.theme.brandPrimary)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.theme.brandSoft)
                        )
                }
            }

            Picker("Transaction type", selection: $transactionKind) {
                Text("Buy").tag(TransactionKind.buy)
                Text("Sell").tag(TransactionKind.sell)
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Text("Amount")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.theme.textSecondary)

                HStack(spacing: 6) {
                    TextField(
                        "",
                        text: $quantityText,
                        prompt: Text("0.00").foregroundColor(Color.theme.textTertiary)
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(Color.theme.textPrimary)
                    .tint(Color.theme.brandPrimary)
                    .focused($isQuantityFocused)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityLabel("Amount of \(coin.symbol.uppercased())")

                    Text(coin.symbol.uppercased())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.surfaceTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isQuantityFocused ? Color.theme.brandPrimary : Color.theme.borderSubtle,
                            lineWidth: 1
                        )
                )
                .contentShape(Rectangle())
                .onTapGesture { isQuantityFocused = true }
            }

            HStack(spacing: 12) {
                Text(transactionKind == .sell ? "Price sold at" : "Price paid")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.theme.textSecondary)

                Spacer(minLength: 8)

                TextField(
                    "",
                    text: $priceText,
                    prompt: Text("0.00").foregroundColor(Color.theme.textTertiary)
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color.theme.textPrimary)
                .tint(Color.theme.brandPrimary)
                .focused($isPriceFocused)
                .frame(maxWidth: 140)
                .accessibilityLabel("Price per coin")

                Text("USD")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.theme.textSecondary)
            }

            DatePicker(
                "Date",
                selection: $transactionDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .font(.system(size: 13))
            .foregroundStyle(Color.theme.textSecondary)
            .tint(Color.theme.brandPrimary)

            Divider()
                .overlay(Color.theme.borderSubtle)

            HStack {
                Text(transactionKind == .sell ? "Proceeds" : "Total cost")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.theme.textSecondary)

                Spacer(minLength: 8)

                Text(currentValue.asCurrencyWith2Decimals())
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(Color.theme.textPrimary)
            }

            Text(hintText(for: coin))
                .font(.system(size: 11))
                .foregroundStyle(Color.theme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: Metrics.panelCornerRadius, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.panelCornerRadius, style: .continuous)
                .strokeBorder(Color.theme.brandPrimary, lineWidth: 1)
        )
    }

    private func hintText(for coin: CoinModel) -> String {
        let symbol = coin.symbol.uppercased()
        let holdings = vm.currentHoldings(for: coin)

        if transactionKind == .sell {
            guard let holdings else { return "You don't hold any \(symbol) yet" }

            if sellsMoreThanHeld {
                return "You only hold \(Self.heldAmountString(holdings)) \(symbol)"
            }

            return "Currently holding \(Self.heldAmountString(holdings)) \(symbol)"
        }

        guard let holdings else {
            return "Records a buy · price defaults to today's"
        }

        return "Currently holding \(Self.heldAmountString(holdings)) \(symbol) · this adds to it"
    }

    private var sellsMoreThanHeld: Bool {
        guard transactionKind == .sell,
              let coin = selectedCoin,
              let amount = Double(quantityText), amount > 0 else {
            return false
        }

        return amount > (vm.currentHoldings(for: coin) ?? 0)
    }

    private var pricePerCoin: Double {
        Double(priceText) ?? selectedCoin?.currentPrice ?? 0
    }

    private var currentValue: Double {
        guard let quantity = Double(quantityText) else { return 0 }

        return quantity * pricePerCoin
    }
}

// MARK: - Save Bar

extension PortfolioEditorView {
    private var saveBar: some View {
        Button {
            saveButtonPressed()
        } label: {
            Text(saveButtonTitle)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(canSave ? Color.theme.surfaceBackground : Color.theme.textTertiary)
                .background(
                    RoundedRectangle(cornerRadius: Metrics.rowCornerRadius, style: .continuous)
                        .fill(canSave ? Color.theme.brandPrimary : Color.theme.surfaceTertiary)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSave)
        .padding(.horizontal, Metrics.horizontalInset)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(alignment: .top) {
            Color.theme.surfaceBackground
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.theme.borderSubtle)
                        .frame(height: 1)
                }
        }
    }

    private var saveButtonTitle: String {
        guard let coin = selectedCoin else {
            return "Select a coin"
        }

        let verb = transactionKind == .sell ? "Sell" : "Buy"
        let symbol = coin.symbol.uppercased()

        guard let amount = Double(quantityText), amount > 0 else {
            return "Enter an amount"
        }

        return "\(verb) \(Self.enteredAmountString(quantityText, fallback: amount)) \(symbol)"
    }
}

// MARK: - Actions

extension PortfolioEditorView {
    private var canSave: Bool {
        guard selectedCoin != nil,
              let amount = Double(quantityText),
              amount > 0,
              pricePerCoin >= 0,
              !sellsMoreThanHeld else {
            return false
        }

        return true
    }

    private func selectCoin(_ coin: CoinModel) {
        selectedCoin = coin
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        quantityText = ""
        priceText = String(format: "%.2f", coin.currentPrice)
        transactionDate = Date()

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

        vm.addTransaction(
            coin: coin,
            kind: transactionKind,
            amount: amount,
            pricePerCoin: pricePerCoin,
            date: transactionDate
        )
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIAccessibility.post(notification: .announcement, argument: "\(coin.name) transaction saved")
        UIApplication.shared.endEditing()
        dismiss()
    }
}

// MARK: - Amount Formatting

extension PortfolioEditorView {
    private static let heldAmountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
    }()

    /// Display string for an existing holding, e.g. `0.4000 held` / `12,500 held`.
    fileprivate static func heldAmountString(_ value: Double) -> String {
        if value != value.rounded(), value < 1 {
            // Small fractional holdings read better with a fixed 4 decimal places.
            return String(format: "%.4f", value)
        }

        return heldAmountFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    /// Plain, locale-independent representation used to prefill the amount field.
    fileprivate static func plainAmountString(_ value: Double) -> String {
        if value == value.rounded(), abs(value) < 1e15 {
            return String(format: "%.0f", value)
        }

        var text = String(format: "%.8f", value)
        while text.hasSuffix("0") {
            text.removeLast()
        }
        if text.hasSuffix(".") {
            text.removeLast()
        }

        return text
    }

    /// Echoes what the user typed in the save button label, tidying up partial input.
    fileprivate static func enteredAmountString(_ text: String, fallback: Double) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty, !trimmed.hasSuffix("."), trimmed != "." else {
            return plainAmountString(fallback)
        }

        return trimmed
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
