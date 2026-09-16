//
//  DetailView.swift
//  Crypter
//
//

import SwiftUI
import Charts

struct DetailView<ViewModel>: View where ViewModel: DetailViewModel {
    @StateObject var vm: ViewModel
    @EnvironmentObject var core: Core
    @EnvironmentObject var watchlist: WatchlistStore
    @AppStorage("hidesPortfolioBalances") private var hidesBalances: Bool = false
    @State private var showFullDescription: Bool = false
    @State private var showTransactionEditor: Bool = false
    @State private var editingTransaction: PortfolioTransaction? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                priceHeader

                ChartView(
                    coin: vm.coin,
                    points: vm.chartPoints,
                    isLoading: vm.isLoadingChart,
                    errorMessage: vm.chartErrorMessage,
                    onRangeChange: { range in
                        vm.fetchMarketChart(range: range)
                    }
                )

                if let holdings = vm.coin.currentHoldings, holdings > 0 {
                    positionCard(holdings: holdings)
                }

                if let low = vm.coin.low24H, let high = vm.coin.high24H, high > low {
                    rangeSection(low: low, high: high)
                }

                if !vm.transactions.isEmpty {
                    transactionsSection
                }

                if !vm.overViewStatistics.isEmpty {
                    section(title: "Market stats", meta: "via CoinGecko") {
                        statsGrid(vm.overViewStatistics)
                    }
                }

                if !vm.additionalStatistics.isEmpty {
                    section(title: "Additional details") {
                        statsGrid(vm.additionalStatistics)
                    }
                }

                if let coinDescription = vm.coinDescription, !coinDescription.isEmpty {
                    section(title: "About \(vm.coin.name)") {
                        descriptionBlock(description: coinDescription)
                    }
                }

                if hasLinks {
                    linkSection
                }

                attribution
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.theme.surfaceBackground.ignoresSafeArea())
        .navigationTitle(vm.coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navigationTitleContent
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                watchlistButton
            }
        }
        .safeAreaInset(edge: .bottom) {
            addTransactionBar
        }
        .sheet(isPresented: $showTransactionEditor) {
            HomeAddHoldingSheet(
                vm: HomeAddHoldingViewModel(
                    coin: vm.coin,
                    portfolioDataService: core.portfolioDataService
                )
            )
            .environmentObject(core)
        }
        .sheet(item: $editingTransaction) { transaction in
            TransactionEditorSheet(
                transaction: transaction,
                symbol: vm.coin.symbol.uppercased(),
                siblings: vm.transactions,
                onSave: { kind, amount, price, date in
                    core.portfolioDataService.updateTransaction(
                        id: transaction.id,
                        kind: kind,
                        amount: amount,
                        pricePerCoin: price,
                        date: date
                    )
                },
                onDelete: {
                    core.portfolioDataService.deleteTransaction(id: transaction.id)
                }
            )
        }
    }
}

extension DetailView {
    private var isWatched: Bool {
        watchlist.contains(vm.coin)
    }

    /// Stocks-style: the coin's own page is the primary place to start watching it.
    private var watchlistButton: some View {
        Button {
            let added = watchlist.toggle(vm.coin)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            UIAccessibility.post(
                notification: .announcement,
                argument: added ? "\(vm.coin.name) added to watchlist" : "\(vm.coin.name) removed from watchlist"
            )
        } label: {
            Image(systemName: isWatched ? "star.fill" : "star")
                .foregroundColor(isWatched ? Color.theme.brandPrimary : Color.theme.textPrimary)
        }
        .accessibilityLabel(isWatched ? "Remove from watchlist" : "Add to watchlist")
    }
}

// MARK: - Transactions

extension DetailView {
    /// The coin's own history, so a position can be checked without leaving the page.
    private var transactionsSection: some View {
        section(title: "Your transactions", meta: vm.transactions.count == 1 ? "1 entry" : "\(vm.transactions.count) entries") {
            VStack(spacing: 0) {
                if let holding = vm.holding {
                    positionSummary(holding)

                    Rectangle()
                        .fill(Color.theme.borderSubtle)
                        .frame(height: 1)
                }

                ForEach(Array(vm.transactions.enumerated()), id: \.element.id) { index, transaction in
                    transactionRow(transaction)

                    if index < vm.transactions.count - 1 {
                        Rectangle()
                            .fill(Color.theme.borderSubtle)
                            .frame(height: 1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(cardBackground)
        }
    }

    private var realizedTotal: Double? {
        let profits = vm.transactions.compactMap { vm.realizedProfit(for: $0) }
        guard !profits.isEmpty else { return nil }
        return profits.reduce(0, +)
    }

    private func positionSummary(_ holding: PortfolioHolding) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                summaryColumn(
                    title: "Holding",
                    value: holding.amount.asNumberString() + " " + vm.coin.symbol.uppercased(),
                    color: Color.theme.textPrimary
                )

                Spacer()

                summaryColumn(
                    title: "Average cost",
                    value: holding.averageCost?.asCurrencyWith2Decimals() ?? "Unknown",
                    color: holding.averageCost == nil ? Color.theme.textTertiary : Color.theme.textPrimary,
                    alignment: .trailing
                )
            }

            HStack(alignment: .top) {
                if let profit = vm.coin.totalProfit, let percent = vm.coin.totalProfitPercentage {
                    summaryColumn(
                        title: "Unrealized",
                        value: (profit >= 0 ? "+" : "-") + abs(profit).asCurrencyWith2Decimals() + " · " + abs(percent).asPercentString(),
                        color: profit >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
                    )
                }

                Spacer()

                if let realizedTotal {
                    summaryColumn(
                        title: "Realized",
                        value: (realizedTotal >= 0 ? "+" : "-") + abs(realizedTotal).asCurrencyWith2Decimals(),
                        color: realizedTotal >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger,
                        alignment: .trailing
                    )
                }
            }
        }
        .padding(.vertical, 14)
    }

    private func summaryColumn(
        title: String,
        value: String,
        color: Color,
        alignment: HorizontalAlignment = .leading
    ) -> some View {
        VStack(alignment: alignment, spacing: 3) {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(color)
        }
    }

    private func transactionRow(_ transaction: PortfolioTransaction) -> some View {
        let tint: Color = {
            switch transaction.kind {
            case .buy: return Color.theme.statusSuccess
            case .sell: return Color.theme.statusDanger
            case .opening: return Color.theme.textSecondary
            }
        }()

        let realized = vm.realizedProfit(for: transaction)

        return HStack(spacing: 12) {
            Image(systemName: transaction.kind.iconName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tint.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.kind.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text(transaction.hasCostBasis
                     ? "\(transaction.date.formatted(.dateTime.month(.abbreviated).day())) · @ \(transaction.pricePerCoin.asCurrencyWith2Decimals())"
                     : "\(transaction.date.formatted(.dateTime.month(.abbreviated).day())) · price unknown")
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text((transaction.kind == .sell ? "-" : "+") + transaction.amount.asNumberString() + " " + vm.coin.symbol.uppercased())
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)

                if let realized {
                    Text(((realized >= 0 ? "+" : "-") + abs(realized).asCurrencyWith2Decimals()) + " realized")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(realized >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger)
                } else {
                    Text(transaction.hasCostBasis ? transaction.totalValue.asCurrencyWith2Decimals() : "No cost basis")
                        .font(.system(size: 12, design: transaction.hasCostBasis ? .monospaced : .default))
                        .foregroundColor(Color.theme.textTertiary)
                }
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture { editingTransaction = transaction }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private var addTransactionBar: some View {
        Button {
            showTransactionEditor = true
        } label: {
            Label("Add transaction", systemImage: "plus")
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(Color.theme.surfaceBackground)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.theme.brandPrimary)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
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
}

// MARK: - Header

extension DetailView {

    private var changeColor: Color {
        (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger
    }

    private var changeSoftColor: Color {
        (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.statusSuccessSoft : Color.theme.statusDangerSoft
    }

    private var priceText: String {
        vm.coin.currentPrice >= 1 ? vm.coin.currentPrice.asCurrencyWith2Decimals() : vm.coin.currentPrice.asCurrencyWith6Decimals()
    }

    private var priceHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(vm.coin.symbol.uppercased()) / USD")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)

            Text(priceText)
                .font(.system(size: 38, weight: .semibold, design: .monospaced))
                .kerning(-1.2)
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .contentTransition(.numericText())

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11, weight: .bold))

                    Text(signedPercent(vm.coin.priceChangePercentage24H ?? 0))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(changeColor)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(changeSoftColor)
                )

                if let priceChange = vm.coin.priceChange24H {
                    Text("\(signedCurrency(priceChange)) today")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(changeColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var navigationTitleContent: some View {
        HStack(spacing: 8) {
            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: vm.coin))
                .frame(width: 24, height: 24)
                .clipShape(Circle())

            Text(vm.coin.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)

            if vm.coin.rank > 0 {
                Text("#\(vm.coin.rank)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.theme.surfaceTertiary)
                    )
            }
        }
    }
}

// MARK: - Sections

extension DetailView {

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        meta: String? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Spacer(minLength: 8)

                if let meta {
                    Text(meta)
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textTertiary)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func positionCard(holdings: Double) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "wallet.bifold")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.theme.brandPrimary)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.brandSoft)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text("Your holdings")
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)

                Text(hidesBalances ? CoinRowView.maskedValue : holdingsAmountText(holdings))
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 3) {
                Text(hidesBalances ? CoinRowView.maskedValue : vm.coin.currentHoldingsValue.asCurrencyWith2Decimals())
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let priceChange = vm.coin.priceChange24H, !hidesBalances {
                    Text(signedCurrency(holdings * priceChange))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(changeColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
        .contentTransition(.numericText())
        .padding(16)
        .background(cardBackground)
    }

    private func rangeSection(low: Double, high: Double) -> some View {
        section(title: "24h range") {
            VStack(alignment: .leading, spacing: 10) {
                RangeTrack(low: low, high: high, current: vm.coin.currentPrice)

                HStack {
                    rangeLabel("Low", value: low)
                    Spacer(minLength: 12)
                    rangeLabel("High", value: high)
                }
            }
        }
    }

    private func rangeLabel(_ title: String, value: Double) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color.theme.textTertiary)

            Text(value >= 1 ? value.asCurrencyWith2Decimals() : value.asCurrencyWith6Decimals())
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func statsGrid(_ stats: [StatisticModel]) -> some View {
        let rows = stride(from: 0, to: stats.count, by: 2).map { start in
            Array(stats[start..<min(start + 2, stats.count)])
        }

        return VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Divider()
                        .overlay(Color.theme.borderSubtle)
                }

                HStack(spacing: 0) {
                    statCell(row[0])

                    Divider()
                        .overlay(Color.theme.borderSubtle)

                    if row.count > 1 {
                        statCell(row[1])
                    } else {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .background(cardBackground)
    }

    private func statCell(_ stat: StatisticModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(stat.title)
                .font(.system(size: 12))
                .foregroundColor(Color.theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(stat.value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())

            Text(stat.percentageChange.map { signedPercent($0) + " 24h" } ?? "—")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(
                    stat.percentageChange.map { $0 >= 0 ? Color.theme.statusSuccess : Color.theme.statusDanger }
                        ?? Color.theme.textTertiary
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }

    private func descriptionBlock(description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(description)
                .font(.system(size: 14))
                .lineSpacing(6)
                .foregroundColor(Color.theme.textSecondary)
                .lineLimit(showFullDescription ? nil : 4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showFullDescription.toggle()
                }
            } label: {
                Text(showFullDescription ? "Show less" : "Read more")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.theme.brandPrimary)
            }
            .buttonStyle(.plain)
        }
    }

    private var hasLinks: Bool {
        vm.websiteURL != nil || vm.redditURL != nil
    }

    private var linkSection: some View {
        HStack(spacing: 8) {
            if let websiteURL = vm.websiteURL {
                linkChip(for: websiteURL, title: "Website", icon: "globe")
            }
            if let redditURL = vm.redditURL {
                linkChip(for: redditURL, title: "Reddit", icon: "bubble.left.and.bubble.right")
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func linkChip(for urlString: String, title: String, icon: String) -> some View {
        if let url = URL(string: urlString) {
            Link(destination: url) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textSecondary)

                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.theme.textPrimary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.theme.surfaceSecondary)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.theme.borderSubtle, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var attribution: some View {
        Label("Data by CoinGecko", systemImage: "cylinder.split.1x2")
            .font(.system(size: 11))
            .foregroundColor(Color.theme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 4)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.theme.surfaceSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.theme.borderSubtle, lineWidth: 1)
            )
    }
}

// MARK: - Formatting helpers

extension DetailView {

    private func signedPercent(_ value: Double) -> String {
        (value >= 0 ? "+" : "") + value.asPercentString()
    }

    private func signedCurrency(_ value: Double) -> String {
        let magnitude = abs(value)
        let formatted = magnitude >= 1 ? magnitude.asCurrencyWith2Decimals() : magnitude.asCurrencyWith6Decimals()
        return (value < 0 ? "-" : "+") + formatted
    }

    private func holdingsAmountText(_ holdings: Double) -> String {
        let amount = NSNumber(value: holdings)
        let formatted = Self.holdingsFormatter.string(from: amount) ?? "0"
        return formatted + " " + vm.coin.symbol.uppercased()
    }

    private static var holdingsFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
    }
}

// MARK: - Range Track

struct RangeTrack: View {
    let low: Double
    let high: Double
    let current: Double

    private var fraction: Double {
        guard high > low else { return 0.5 }
        return min(max((current - low) / (high - low), 0), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let markerSize: CGFloat = 10

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.theme.surfaceTertiary)
                    .frame(height: 4)

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.theme.statusDanger, Color.theme.statusSuccess],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(markerSize, width * fraction), height: 4)

                Circle()
                    .fill(Color.theme.textPrimary)
                    .frame(width: markerSize, height: markerSize)
                    .overlay(
                        Circle().stroke(Color.theme.surfaceBackground, lineWidth: 2)
                    )
                    .offset(x: min(max(width * fraction - markerSize / 2, 0), width - markerSize))
            }
            .frame(width: width, height: markerSize)
            .frame(maxHeight: .infinity)
        }
        .frame(height: 10)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetailView(vm: PreviewDetailViewModel())
                .environmentObject(Core.preview)
        }
        .preferredColorScheme(.dark)
    }
}
