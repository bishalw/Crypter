//
//  TransactionListSheet.swift
//  Crypter
//

import SwiftUI

struct TransactionListSheet: View {
    let transactions: [PortfolioTransaction]
    let coins: [CoinModel]
    let realizedProfit: (PortfolioTransaction) -> Double?
    let onSelect: (PortfolioTransaction) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all, buys, sells

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: return "All"
            case .buys: return "Buys"
            case .sells: return "Sells"
            }
        }
    }

    private var filtered: [PortfolioTransaction] {
        switch filter {
        case .all: return transactions
        case .buys: return transactions.filter { $0.kind != .sell }
        case .sells: return transactions.filter { $0.kind == .sell }
        }
    }

    private var grouped: [(month: String, transactions: [PortfolioTransaction])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filtered) { transaction in
            calendar.dateInterval(of: .month, for: transaction.date)?.start ?? transaction.date
        }

        return groups
            .sorted { $0.key > $1.key }
            .map { (month: $0.key.formatted(.dateTime.month(.wide).year()), transactions: $0.value) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitleIfAvailable(summary)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.theme.brandPrimary)
                }
            }
        }
    }

    private var summary: String {
        let count = filtered.count
        return count == 1 ? "1 entry" : "\(count) entries"
    }

    private var list: some View {
        List {
            Picker("Filter", selection: $filter) {
                ForEach(Filter.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
            .listRowBackground(Color.theme.surfaceBackground)
            .listRowSeparator(.hidden)

            ForEach(grouped, id: \.month) { group in
                Section {
                    ForEach(group.transactions) { transaction in
                        Button {
                            onSelect(transaction)
                            dismiss()
                        } label: {
                            row(transaction)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .listRowBackground(Color.theme.surfaceBackground)
                        .listRowSeparatorTint(Color.theme.borderSubtle)
                    }
                } header: {
                    Text(group.month)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.theme.textTertiary)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(_ transaction: PortfolioTransaction) -> some View {
        let symbol = coins.first(where: { $0.id == transaction.coinID })?.symbol.uppercased()
            ?? transaction.coinID.uppercased()
        let tint: Color = {
            switch transaction.kind {
            case .buy: return Color.theme.statusSuccess
            case .sell: return Color.theme.statusDanger
            case .opening: return Color.theme.textSecondary
            }
        }()
        let realized = realizedProfit(transaction)

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
                Text("\(transaction.kind.title) \(symbol)")
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
                Text((transaction.kind == .sell ? "-" : "+") + transaction.amount.asNumberString() + " " + symbol)
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
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Nothing here")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color.theme.textPrimary)
            Text(filter == .sells ? "You haven't recorded a sell yet." : "You haven't recorded a buy yet.")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
