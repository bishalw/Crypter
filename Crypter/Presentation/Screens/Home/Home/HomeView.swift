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
    @EnvironmentObject var watchlist: WatchlistStore
    @StateObject var vm: ViewModel
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var editorCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    @State private var isSearchPresented: Bool = false
    @State private var showSettings: Bool = false
    @State private var showTrendingList: Bool = false

    private var isShowingSearchResults: Bool {
        !vm.searchText.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // With nothing loaded yet the empty state carries the message,
                    // so the banner would say it twice.
                    if let errorMessage = vm.errorMessage, !vm.allCoins.isEmpty {
                        refreshBanner(errorMessage)
                    }

                    if !isShowingSearchResults {
                        HomeStatsView(statistics: vm.statistics)

                        if !vm.trendingCoins.isEmpty {
                            TrendingStripView(
                                coins: vm.trendingCoins,
                                onSelect: { vm.searchText = $0.name },
                                onSeeAll: { showTrendingList = true }
                            )
                        }
                    }

                    VStack(spacing: 4) {
                        sortPills
                            .padding(.bottom, 12)

                        listColumnHeader

                        if vm.allCoins.isEmpty && !vm.searchText.isEmpty && vm.isSearching {
                            searchingRows
                        } else if vm.allCoins.isEmpty && !vm.searchText.isEmpty {
                            noResults
                        } else if vm.allCoins.isEmpty && vm.errorMessage != nil && !vm.isLoading {
                            failedFirstLoad
                        } else if vm.allCoins.isEmpty {
                            placeholderRows
                        } else {
                            allCoinsList
                        }
                    }

                    footer
                }
                .padding(.horizontal)
                .padding(.bottom)
                .animation(.easeInOut(duration: 0.2), value: isShowingSearchResults)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Markets")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $vm.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: Text("Search coins")
            )
            .autocorrectionDisabled()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showTrendingList) {
                TrendingListSheet(coins: vm.trendingCoins) { coin in
                    vm.searchText = coin.name
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    onCurrencyChange: { vm.reloadData() },
                    vm: SettingsViewModel(
                        portfolioDataService: core.portfolioDataService,
                        watchlistStore: watchlist
                    )
                )
                .environmentObject(core.apiKeyStore)
            }
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
                    DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.cryptoStore, portfolioDataService: core.portfolioDataService))
                }
            }
            .refreshable {
                vm.reloadData()
            }
        }
    }

    /// Shown above the list when a refresh failed: the prices already on screen
    /// stay visible, since stale prices beat a blank screen.
    private func refreshBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.statusDanger)

            Text(message)
                .font(.system(size: 12))
                .foregroundColor(Color.theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Retry") {
                vm.reloadData()
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color.theme.brandPrimary)
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.theme.statusDangerSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.borderSubtle, lineWidth: 1)
        )
    }

    /// Nothing loaded and the refresh failed: the list has nothing to show, so
    /// the failure becomes the content rather than a note above empty space.
    private var failedFirstLoad: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(Color.theme.textTertiary)

            VStack(spacing: 6) {
                Text("Couldn't load coins")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text(vm.errorMessage ?? "")
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                vm.reloadData()
            } label: {
                Text("Try again")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.surfaceBackground)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule().fill(Color.theme.brandPrimary)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 48)
    }

    /// Shown while the remote search runs, so an unlisted coin does not read as
    /// "no results" before the answer arrives.
    private var searchingRows: some View {
        HStack(spacing: 10) {
            ProgressView()
                .tint(Color.theme.textSecondary)

            Text("Searching all coins…")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var placeholderRows: some View {
        VStack(spacing: 4) {
            ForEach(0..<8, id: \.self) { _ in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.theme.surfaceSecondary)
                        .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.theme.surfaceSecondary)
                            .frame(width: 96, height: 12)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.theme.surfaceSecondary)
                            .frame(width: 64, height: 10)
                    }

                    Spacer()

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.theme.surfaceSecondary)
                        .frame(width: 72, height: 12)
                }
                .padding(.vertical, 12)
            }
        }
        .redacted(reason: .placeholder)
        .accessibilityLabel("Loading coins")
    }

    private var noResults: some View {
        VStack(spacing: 6) {
            Text("No results")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.theme.textPrimary)
            Text("No coins match \u{201C}\(vm.searchText)\u{201D}")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var sortPillOptions: [(title: String, option: SortOption)] {
        [
            ("Top 100", .rank),
            ("Gainers", .gainers),
            ("Losers", .losers),
            ("Price ↑", .price),
            ("Price ↓", .priceReversed)
        ]
    }

    private var sortPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sortPillOptions, id: \.title) { pill in
                    let isSelected = vm.sortOption == pill.option
                    Button {
                        vm.sortOption = pill.option
                    } label: {
                        Text(pill.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isSelected ? Color.theme.surfaceBackground : Color.theme.textSecondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(
                                Capsule().fill(isSelected ? Color.theme.textPrimary : Color.theme.surfaceSecondary)
                            )
                            .overlay(
                                Capsule().stroke(isSelected ? Color.clear : Color.theme.borderSubtle, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }

    private var listColumnHeader: some View {
        HStack {
            Text("#  Name · Market cap")
            Spacer()
            Text("Price / 24h")
        }
        .font(.system(size: 11))
        .foregroundColor(Color.theme.textTertiary)
        .padding(.vertical, 4)
    }
    
    private var allCoinsList: some View {
        VStack(spacing: 4) {
            ForEach(vm.allCoins) { coin in
                Button {
                    selectedCoin = coin
                    showDetailView = true
                } label: {
                    CoinRowView(coin: coin, showHoldingsColumn: false, showSparkline: true)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        let added = watchlist.toggle(coin)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        UIAccessibility.post(
                            notification: .announcement,
                            argument: added ? "\(coin.name) added to watchlist" : "\(coin.name) removed from watchlist"
                        )
                    } label: {
                        Label(
                            watchlist.contains(coin) ? "Remove from Watchlist" : "Add to Watchlist",
                            systemImage: watchlist.contains(coin) ? "star.slash" : "star"
                        )
                    }

                    Button {
                        editorCoin = coin
                    } label: {
                        Label("Add to Portfolio", systemImage: "plus.circle")
                    }
                }
            }
        }
    }

    private var footer: some View {
        Text("Market data by CoinGecko")
            .font(.caption2)
            .foregroundColor(Color.theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(vm: PreviewHomeViewModel())
            .environmentObject(Core.preview)
            .environmentObject(WatchlistStore())
    }
}

final class HomeAddHoldingViewModel: ObservableObject {
    @Published var quantityText: String = ""
    @Published var priceText: String = ""
    @Published var kind: TransactionKind = .buy
    @Published var date: Date = Date()
    @Published private(set) var currentHoldings: Double?

    let coin: CoinModel

    private let portfolioDataService: PortfolioDataService
    private var cancellables = Set<AnyCancellable>()
    private var didLoadInitialQuantity = false

    init(coin: CoinModel, portfolioDataService: PortfolioDataService) {
        self.coin = coin
        self.portfolioDataService = portfolioDataService
        self.priceText = String(format: "%.2f", coin.currentPrice)
        bind()
    }

    var pricePerCoin: Double {
        Double(priceText) ?? coin.currentPrice
    }

    var liveValue: Double {
        guard let quantity = Double(quantityText) else { return 0 }
        return quantity * pricePerCoin
    }

    var canSave: Bool {
        guard let amount = Double(quantityText), amount > 0 else { return false }

        if kind == .sell, let currentHoldings {
            return amount <= currentHoldings
        }

        return kind == .buy
    }

    var currentHoldingsText: String? {
        guard let currentHoldings, currentHoldings > 0 else { return nil }
        return "Currently holding \(currentHoldings.asNumberString()) \(coin.symbol.uppercased())"
    }

    var sellsMoreThanHeld: Bool {
        guard kind == .sell, let amount = Double(quantityText), amount > 0 else { return false }
        return amount > (currentHoldings ?? 0)
    }

    func saveTransaction() {
        guard let amount = Double(quantityText), amount > 0 else { return }

        portfolioDataService.addTransaction(
            coin: coin,
            kind: kind,
            amount: amount,
            pricePerCoin: pricePerCoin,
            date: date
        )
    }

    private func bind() {
        portfolioDataService.savedEntitiesPublisher
            .map { [weak self] holdings -> Double? in
                guard let self else { return nil }
                return holdings.first(where: { $0.coinID == self.coin.id })?.amount
            }
            .sink { [weak self] holdings in
                self?.currentHoldings = holdings
            }
            .store(in: &cancellables)
    }
}

struct HomeAddHoldingSheet: View {
    @EnvironmentObject var core: Core
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isQuantityFocused: Bool
    @FocusState private var isPriceFocused: Bool
    @StateObject var vm: HomeAddHoldingViewModel

    private var priceChangeColor: Color {
        (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    coinHeaderCard

                    kindPicker

                    inputCard

                    if vm.liveValue > 0 {
                        valueCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding()
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle(vm.kind == .sell ? "Sell \(vm.coin.symbol.uppercased())" : "Buy \(vm.coin.symbol.uppercased())")
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
                    Button("Save") {
                        saveTransaction()
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
    private var kindPicker: some View {
        Picker("Transaction type", selection: $vm.kind) {
            Text("Buy").tag(TransactionKind.buy)
            Text("Sell").tag(TransactionKind.sell)
        }
        .pickerStyle(.segmented)
    }

    private var coinHeaderCard: some View {
        HStack(spacing: 16) {
            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: vm.coin))
                .frame(width: 44, height: 44)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(vm.coin.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                Text(vm.coin.symbol.uppercased())
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(vm.coin.currentPrice.asCurrencyWith6Decimals())
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)

                Text(vm.coin.priceChangePercentage24H?.asPercentString() ?? "0.00%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(priceChangeColor)
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var inputCard: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Text("Amount")
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                TextField(
                    "",
                    text: $vm.quantityText,
                    prompt: Text("0.00").foregroundColor(Color.theme.textTertiary)
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 24, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .focused($isQuantityFocused)

                Text(vm.coin.symbol.uppercased())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            Divider()
                .overlay(Color.theme.borderSubtle)

            HStack {
                Text(vm.kind == .sell ? "Price sold at" : "Price paid")
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)

                Spacer()

                TextField(
                    "",
                    text: $vm.priceText,
                    prompt: Text("0.00").foregroundColor(Color.theme.textTertiary)
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .focused($isPriceFocused)

                Text("USD")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }

            Divider()
                .overlay(Color.theme.borderSubtle)

            DatePicker(
                "Date",
                selection: $vm.date,
                in: ...Date(),
                displayedComponents: .date
            )
            .font(.system(size: 13))
            .foregroundColor(Color.theme.textSecondary)
            .tint(Color.theme.brandPrimary)

            if vm.sellsMoreThanHeld {
                Text("You only hold \(vm.currentHoldingsText ?? "0")")
                    .font(.system(size: 11))
                    .foregroundColor(Color.theme.statusDanger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let currentHoldingsText = vm.currentHoldingsText {
                Text(currentHoldingsText)
                    .font(.system(size: 11))
                    .foregroundColor(Color.theme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(cardBackground)
    }

    private var valueCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.kind == .sell ? "Proceeds" : "Total cost")
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)
                Text(vm.liveValue.asCurrencyWith2Decimals())
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                    .contentTransition(.numericText())
            }
            Spacer()
        }
        .padding()
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.theme.surfaceSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.theme.borderSubtle, lineWidth: 1)
            )
    }

    private func saveTransaction() {
        vm.saveTransaction()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIAccessibility.post(notification: .announcement, argument: "\(vm.coin.name) transaction saved")
        UIApplication.shared.endEditing()
        dismiss()
    }
}
