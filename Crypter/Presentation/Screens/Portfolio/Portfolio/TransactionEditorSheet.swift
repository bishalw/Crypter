//
//  TransactionEditorSheet.swift
//  Crypter
//

import SwiftUI
import UIKit

/// Edits one existing transaction. Adding is done from the coin sheets; this is
/// the "I typed it wrong" path, and it is also where a transaction is deleted.
struct TransactionEditorSheet: View {
    let transaction: PortfolioTransaction
    let symbol: String
    /// Every transaction for this coin, used to check the edit keeps the
    /// history consistent (no sell ending up larger than what was held).
    let siblings: [PortfolioTransaction]

    let onSave: (TransactionKind, Double, Double, Date) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool
    @FocusState private var isPriceFocused: Bool

    @State private var kind: TransactionKind
    @State private var amountText: String
    @State private var priceText: String
    @State private var date: Date
    @State private var showDeleteConfirmation = false

    init(
        transaction: PortfolioTransaction,
        symbol: String,
        siblings: [PortfolioTransaction],
        onSave: @escaping (TransactionKind, Double, Double, Date) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.transaction = transaction
        self.symbol = symbol
        self.siblings = siblings
        self.onSave = onSave
        self.onDelete = onDelete

        _kind = State(initialValue: transaction.kind == .opening ? .buy : transaction.kind)
        _amountText = State(initialValue: Self.plainNumber(transaction.amount))
        _priceText = State(initialValue: transaction.hasCostBasis ? Self.plainNumber(transaction.pricePerCoin) : "")
        _date = State(initialValue: transaction.date)
    }

    private var amount: Double? {
        guard let value = Double(amountText), value > 0 else { return nil }
        return value
    }

    private var price: Double? {
        guard let value = Double(priceText), value >= 0 else { return nil }
        return value
    }

    private var total: Double {
        (amount ?? 0) * (price ?? 0)
    }

    private var edit: PortfolioTransaction? {
        guard let amount, let price else { return nil }

        return PortfolioTransaction(
            id: transaction.id,
            coinID: transaction.coinID,
            kind: kind,
            amount: amount,
            pricePerCoin: price,
            hasCostBasis: true,
            date: date
        )
    }

    private var wouldOversell: Bool {
        guard let edit else { return false }

        let updated = siblings.map { $0.id == edit.id ? edit : $0 }
        return !PortfolioDataServiceImpl.isConsistent(updated)
    }

    private var canSave: Bool {
        amount != nil && price != nil && !wouldOversell
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Picker("Transaction type", selection: $kind) {
                    Text("Buy").tag(TransactionKind.buy)
                    Text("Sell").tag(TransactionKind.sell)
                }
                .pickerStyle(.segmented)

                field(label: "Amount", text: $amountText, suffix: symbol, focus: $isAmountFocused, large: true)
                field(label: kind == .sell ? "Price sold at" : "Price paid", text: $priceText, suffix: "USD", focus: $isPriceFocused, large: false)

                DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)
                    .tint(Color.theme.brandPrimary)

                Divider().overlay(Color.theme.borderSubtle)

                HStack {
                    Text(kind == .sell ? "Proceeds" : "Total cost")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)

                    Spacer()

                    Text(total.asCurrencyWith2Decimals())
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.theme.textPrimary)
                }

                if wouldOversell {
                    Text("This would sell more \(symbol) than you held at that point.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.statusDanger)
                        .fixedSize(horizontal: false, vertical: true)
                } else if transaction.kind == .opening {
                    Text("Saving turns this opening balance into a buy, so it joins your all-time profit.")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete transaction", systemImage: "trash")
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundColor(Color.theme.statusDanger)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.theme.statusDangerSoft)
                )
                .padding(.top, 4)

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Edit transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                        .foregroundColor(Color.theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let amount, let price else { return }
                        onSave(kind, amount, price, date)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .foregroundColor(Color.theme.brandPrimary)
                    .disabled(!canSave)
                }
            }
            .confirmationDialog(
                "Delete this transaction?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your holdings will be recalculated without it.")
            }
        }
    }

    private func field(
        label: String,
        text: Binding<String>,
        suffix: String,
        focus: FocusState<Bool>.Binding,
        large: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)

            Spacer(minLength: 8)

            HStack(spacing: 6) {
                TextField(
                    "",
                    text: text,
                    prompt: Text("0.00").foregroundColor(Color.theme.textTertiary)
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: large ? 22 : 15, weight: large ? .semibold : .medium, design: .monospaced))
                .foregroundColor(Color.theme.textPrimary)
                .tint(Color.theme.brandPrimary)
                .focused(focus)
                .accessibilityLabel(label)

                Text(suffix)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .frame(maxWidth: 190)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.theme.surfaceTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        focus.wrappedValue ? Color.theme.brandPrimary : Color.theme.borderSubtle,
                        lineWidth: 1
                    )
            )
        }
    }

    private static func plainNumber(_ value: Double) -> String {
        value == value.rounded() ? String(format: "%.0f", value) : String(value)
    }
}
