//
//  PortFolioTab.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import Foundation
import SwiftUI
import UIKit
import Charts

struct PortfolioView<ViewModel>: View where ViewModel: PortfolioViewModel {

    @EnvironmentObject var core: Core
    @StateObject var vm: ViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    @State private var showPortfolioEditor: Bool = false
    @AppStorage("hidesPortfolioBalances") private var hidesBalances: Bool = false
    @State private var costBasisCoin: CoinModel? = nil
    @State private var editingTransaction: PortfolioTransaction? = nil
    @State private var showAllTransactions: Bool = false
    @StateObject private var lock = PortfolioLock()
    @State private var historyRange: Int = 30
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if lock.isEnabled && !lock.isUnlocked {
                PortfolioLockView(lock: lock)
            } else {
                content
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { lock.lock() }
        }
    }

    private var content: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    if let storeErrorMessage = vm.storeErrorMessage {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.statusDanger)

                            Text(storeErrorMessage)
                                .font(.system(size: 12))
                                .foregroundColor(Color.theme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.theme.statusDangerSoft)
                        )
                    }

                    if vm.portfolioCoins.isEmpty {
                        emptyStateView
                            .padding(.top, 60)
                    } else {
                        balanceSection

                        if core.portfolioHistoryStore.snapshots.count > 1 {
                            historySection
                        }

                        PortfolioAllocationChartView(
                            coins: vm.portfolioCoins,
                            totalValue: vm.totalPortfolioValue,
                            totalChange: vm.totalPortfolio24hChange,
                            hidesValues: hidesBalances
                        )

                        holdingsSection

                        if !vm.recentTransactions.isEmpty {
                            transactionsSection
                        }

                        footer
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitleIfAvailable("Stored on this device")
            .navigationDestination(isPresented: $showDetailView) {
                if let coin = selectedCoin {
                    DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.cryptoStore, portfolioDataService: core.portfolioDataService))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPortfolioEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    .accessibilityLabel("Add holding")
                }
            }
            .sheet(isPresented: $showAllTransactions) {
                TransactionListSheet(
                    transactions: vm.recentTransactions,
                    coins: vm.portfolioCoins,
                    realizedProfit: { vm.realizedProfit(for: $0) },
                    onSelect: { editingTransaction = $0 }
                )
            }
            .sheet(item: $editingTransaction) { transaction in
                TransactionEditorSheet(
                    transaction: transaction,
                    symbol: vm.portfolioCoins.first(where: { $0.id == transaction.coinID })?.symbol.uppercased()
                        ?? transaction.coinID.uppercased(),
                    siblings: vm.recentTransactions.filter { $0.coinID == transaction.coinID },
                    onSave: { kind, amount, price, date in
                        vm.updateTransaction(id: transaction.id, kind: kind, amount: amount, pricePerCoin: price, date: date)
                    },
                    onDelete: {
                        vm.deleteTransaction(id: transaction.id)
                    }
                )
            }
            .sheet(item: $costBasisCoin) { coin in
                CostBasisSheet(coin: coin) { price in
                    vm.setCostBasis(for: coin, pricePerCoin: price)
                }
            }
            .sheet(isPresented: $showPortfolioEditor) {
                PortfolioEditorView(vm: PortfolioEditorViewModel(cryptoStore: core.cryptoStore, portfolioDataService: core.portfolioDataService))
                    .environmentObject(core)
            }
            .refreshable {
                vm.reloadData()
            }
            .onChange(of: vm.totalPortfolioValue) { _, newValue in
                core.portfolioHistoryStore.record(value: newValue)
            }
            .onAppear {
                core.portfolioHistoryStore.record(value: vm.totalPortfolioValue)
            }
        }
    }
}

extension PortfolioView {

    private var todayChangeColor: Color {
        vm.totalPortfolio24hChange >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var todayChangeText: String {
        guard !hidesBalances else { return CoinRowView.maskedValue }
        return Self.signedAmount(vm.totalPortfolio24hChange)
    }

    private var todayChangePercentText: String? {
        abs(vm.totalPortfolio24hChangePercent).asPercentString()
    }

    /// Six- and seven-figure amounts do not fit three to a row, so anything
    /// past five figures is abbreviated.
    private static func signedAmount(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : "-"

        if abs(value) >= 10_000 {
            return sign + DisplayCurrency.current.symbol + abs(value).formattedWithAbbreviations()
        }

        return sign + abs(value).asCurrencyWith2Decimals()
    }

    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                toggleBalances()
            } label: {
                HStack(spacing: 6) {
                    Text("Total balance")
                        .font(.system(size: 13))

                    Image(systemName: hidesBalances ? "eye.slash" : "eye")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color.theme.textSecondary)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(hidesBalances ? "Show balances" : "Hide balances")

            Text(hidesBalances ? CoinRowView.maskedValue : vm.totalPortfolioValue.asCurrencyWith2Decimals())
                .font(.system(size: 40, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())
                .contentShape(Rectangle())
                .onTapGesture { toggleBalances() }

            HStack(alignment: .top, spacing: 12) {
                changeColumn(
                    title: "Today",
                    text: todayChangeText,
                    percent: todayChangePercentText,
                    color: todayChangeColor
                )

                if let allTimeText {
                    changeColumn(
                        title: "All time",
                        text: allTimeText,
                        percent: allTimePercentText,
                        color: allTimeChangeColor
                    )
                }

                if let realizedText {
                    changeColumn(
                        title: "Realized",
                        text: realizedText,
                        percent: nil,
                        color: realizedChangeColor
                    )
                }
            }

            if vm.hasUnknownCostBasis {
                Text("All-time excludes holdings added before transactions · long-press one to set its cost")
                    .font(.system(size: 11))
                    .foregroundColor(Color.theme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggleBalances() {
        withAnimation(.easeInOut(duration: 0.15)) {
            hidesBalances.toggle()
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func changeColumn(title: String, text: String, percent: String?, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)

            Text(text)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let percent {
                Text(percent)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(color.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var realizedChangeColor: Color {
        (vm.totalRealizedProfit ?? 0) >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var realizedText: String? {
        guard let realized = vm.totalRealizedProfit else { return nil }
        guard !hidesBalances else { return CoinRowView.maskedValue }

        return Self.signedAmount(realized)
    }

    private var allTimeChangeColor: Color {
        (vm.allTimeProfit ?? 0) >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var allTimeText: String? {
        guard let profit = vm.allTimeProfit else { return nil }
        guard !hidesBalances else { return CoinRowView.maskedValue }

        return Self.signedAmount(profit)
    }

    private var allTimePercentText: String? {
        guard let percent = vm.allTimeProfitPercent else { return nil }
        return abs(percent).asPercentString()
    }

    private var historySection: some View {
        let snapshots = core.portfolioHistoryStore.snapshots(withinLast: historyRange)
        let change = core.portfolioHistoryStore.change(withinLast: historyRange)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Value over time")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()

                if let change, !hidesBalances {
                    Text((change.amount >= 0 ? "+" : "-") + abs(change.amount).asCompactCurrency()
                         + " · " + abs(change.percent).asPercentString())
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(change.amount >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger)
                }
            }

            Chart {
                ForEach(snapshots) { snapshot in
                    LineMark(
                        x: .value("Date", snapshot.date),
                        y: .value("Value", snapshot.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.theme.brandPrimary)

                    AreaMark(
                        x: .value("Date", snapshot.date),
                        y: .value("Value", snapshot.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.brandPrimary.opacity(0.25), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 120)

            Picker("Range", selection: $historyRange) {
                Text("7D").tag(7)
                Text("30D").tag(30)
                Text("1Y").tag(365)
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.theme.borderSubtle, lineWidth: 1)
        )
    }

    private var sortOptions: [(title: String, option: SortOption)] {
        [
            ("Value", .holdings),
            ("Value ↑", .holdingsReversed),
            ("Price", .price),
            ("Price ↑", .priceReversed)
        ]
    }

    private var sortTitle: String {
        sortOptions.first(where: { $0.option == vm.sortOption })?.title ?? "Value"
    }

    private var holdingsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Holdings")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()

                Menu {
                    Picker("Sort", selection: $vm.sortOption) {
                        Text("Highest value").tag(SortOption.holdings)
                        Text("Lowest value").tag(SortOption.holdingsReversed)
                        Text("Highest price").tag(SortOption.price)
                        Text("Lowest price").tag(SortOption.priceReversed)
                    }
                } label: {
                    Text("Sort: \(sortTitle)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.theme.brandPrimary)
                }
            }
            .padding(.bottom, 6)

            ForEach(Array(vm.portfolioCoins.enumerated()), id: \.element.id) { index, coin in
                Button {
                    selectedCoin = coin
                    showDetailView = true
                } label: {
                    CoinRowView(coin: coin, showHoldingsColumn: true, hidesValues: hidesBalances)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    if coin.averageCost == nil {
                        Button {
                            costBasisCoin = coin
                        } label: {
                            Label("Set cost basis", systemImage: "dollarsign.circle")
                        }
                    }

                    Button(role: .destructive) {
                        withAnimation { vm.removeFromPortfolio(coin: coin) }
                    } label: {
                        Label("Remove from Portfolio", systemImage: "trash")
                    }
                }

                if index < vm.portfolioCoins.count - 1 {
                    Rectangle()
                        .fill(Color.theme.borderSubtle)
                        .frame(height: 1)
                }
            }
        }
    }

    private var transactionsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Recent transactions")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer()

                Button("See all") {
                    showAllTransactions = true
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.theme.brandPrimary)
                .buttonStyle(.plain)
            }
            .padding(.bottom, 6)

            ForEach(Array(vm.recentTransactions.prefix(10).enumerated()), id: \.element.id) { index, transaction in
                transactionRow(transaction)

                if index < min(vm.recentTransactions.count, 10) - 1 {
                    Rectangle()
                        .fill(Color.theme.borderSubtle)
                        .frame(height: 1)
                }
            }
        }
    }

    private func transactionRow(_ transaction: PortfolioTransaction) -> some View {
        let coin = vm.portfolioCoins.first(where: { $0.id == transaction.coinID })
        let symbol = coin?.symbol.uppercased() ?? transaction.coinID.uppercased()
        let tint: Color = {
            switch transaction.kind {
            case .buy: return Color.theme.statusSuccess
            case .sell: return Color.theme.statusDanger
            case .opening: return Color.theme.textSecondary
            }
        }()

        return HStack(spacing: 12) {
            Image(systemName: transaction.kind.iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(transactionTitle(transaction, symbol: symbol))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text(transactionSubtitle(transaction))
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(signedAmountText(transaction, symbol: symbol))
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)

                if let realized = vm.realizedProfit(for: transaction), !hidesBalances {
                    Text(((realized >= 0 ? "+" : "-") + abs(realized).asCurrencyWith2Decimals()) + " realized")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(realized >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger)
                } else {
                    Text(transaction.hasCostBasis ? transaction.totalValue.asCurrencyWith2Decimals() : "Set cost basis")
                        .font(.system(size: 12, design: transaction.hasCostBasis ? .monospaced : .default))
                        .foregroundColor(transaction.hasCostBasis ? Color.theme.textTertiary : Color.theme.brandPrimary)
                }
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            editingTransaction = transaction
        }
        .contextMenu {
            if transaction.kind == .opening, let coin {
                Button {
                    costBasisCoin = coin
                } label: {
                    Label("Set cost basis", systemImage: "dollarsign.circle")
                }
            }

            Button {
                editingTransaction = transaction
            } label: {
                Label("Edit transaction", systemImage: "pencil")
            }

            Button(role: .destructive) {
                withAnimation { vm.deleteTransaction(id: transaction.id) }
            } label: {
                Label("Delete transaction", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private func transactionTitle(_ transaction: PortfolioTransaction, symbol: String) -> String {
        switch transaction.kind {
        case .buy: return "Bought \(symbol)"
        case .sell: return "Sold \(symbol)"
        case .opening: return "Opening balance \(symbol)"
        }
    }

    private func transactionSubtitle(_ transaction: PortfolioTransaction) -> String {
        let date = transaction.date.formatted(.dateTime.month(.abbreviated).day())

        guard transaction.hasCostBasis else { return "\(date) · price unknown" }

        return "\(date) · @ \(transaction.pricePerCoin.asCurrencyWith2Decimals())"
    }

    private func signedAmountText(_ transaction: PortfolioTransaction, symbol: String) -> String {
        guard !hidesBalances else { return CoinRowView.maskedValue }

        let sign = transaction.kind == .sell ? "-" : "+"
        return "\(sign)\(transaction.amount.asNumberString()) \(symbol)"
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 11))
            Text("Holdings stay local · Prices by CoinGecko")
                .font(.system(size: 11))
        }
        .foregroundColor(Color.theme.textTertiary)
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.theme.brandSoft)
                    .frame(width: 140, height: 140)
                
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.theme.brandPrimary)
            }

            VStack(spacing: 8) {
                Text("Build Your Portfolio")
                    .font(.title2)
                    .bold()
                    .foregroundColor(Color.theme.textPrimary)

                Text("Start tracking your crypto assets by adding your first coin.")
                    .font(.callout)
                    .foregroundColor(Color.theme.textSecondary)
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
                .foregroundColor(Color.theme.surfaceBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.theme.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 40)
        }
    }
}

/// Lets a holding carried over from before transaction tracking be given an
/// average purchase price, so it can join the all-time P/L.
struct CostBasisSheet: View {
    let coin: CoinModel
    let onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isPriceFocused: Bool
    @State private var priceText: String = ""

    private var price: Double? {
        guard let value = Double(priceText), value > 0 else { return nil }
        return value
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("What did you pay on average for one \(coin.symbol.uppercased())?")
                    .font(.system(size: 15))
                    .foregroundColor(Color.theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    TextField(
                        "",
                        text: $priceText,
                        prompt: Text("0.00").foregroundColor(Color.theme.textTertiary)
                    )
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                    .tint(Color.theme.brandPrimary)
                    .focused($isPriceFocused)

                    Text("USD")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.surfaceTertiary)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isPriceFocused ? Color.theme.brandPrimary : Color.theme.borderSubtle,
                            lineWidth: 1
                        )
                )

                if let price, let holdings = coin.currentHoldings {
                    Text("Marks your \(holdings.asNumberString()) \(coin.symbol.uppercased()) as bought for \((holdings * price).asCurrencyWith2Decimals())")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Cost basis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .foregroundColor(Color.theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let price else { return }
                        onSave(price)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .foregroundColor(Color.theme.brandPrimary)
                    .disabled(price == nil)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPriceFocused = true
                }
            }
        }
        .presentationDetents([.height(280)])
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
