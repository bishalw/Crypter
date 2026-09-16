//
//  SettingsView.swift
//  Crypter
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

final class SettingsViewModel: ObservableObject {
    @Published private(set) var transactions: [PortfolioTransaction] = []
    @Published private(set) var watchedCount: Int = 0

    private let portfolioDataService: PortfolioDataService
    private let watchlistStore: WatchlistStore
    private var cancellables = Set<AnyCancellable>()

    init(portfolioDataService: PortfolioDataService, watchlistStore: WatchlistStore) {
        self.portfolioDataService = portfolioDataService
        self.watchlistStore = watchlistStore

        portfolioDataService.transactionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.transactions = $0 }
            .store(in: &cancellables)

        watchlistStore.$coinIDs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.watchedCount = $0.count }
            .store(in: &cancellables)
    }

    var storageSummary: String {
        let transactionText = transactions.count == 1 ? "1 transaction" : "\(transactions.count) transactions"
        let watchText = watchedCount == 1 ? "1 coin watched" : "\(watchedCount) coins watched"
        return "\(transactionText) · \(watchText)"
    }

    func resetPortfolio() {
        portfolioDataService.deleteAllTransactions()
    }

    func transactionsCSV() -> String {
        let header = "date,coin,type,amount,price_per_coin,total,has_cost_basis"
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let rows = transactions.sorted(by: { $0.date < $1.date }).map { transaction in
            [
                formatter.string(from: transaction.date),
                transaction.coinID,
                transaction.kind.rawValue,
                String(transaction.amount),
                String(transaction.pricePerCoin),
                String(transaction.totalValue),
                transaction.hasCostBasis ? "yes" : "no",
            ].joined(separator: ",")
        }

        return ([header] + rows).joined(separator: "\n")
    }

    func makeCSVFile() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("crypter-transactions.csv")

        do {
            try transactionsCSV().write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var apiKeyStore: APIKeyStore
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: SettingsViewModel

    @State private var keyText: String = ""
    @State private var showResetConfirmation = false
    @State private var csvURL: URL? = nil
    @FocusState private var isKeyFocused: Bool

    var body: some View {
        NavigationStack {
            List {
                dataSourceSection
                myDataSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .tint(Color.theme.brandPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.theme.brandPrimary)
                }
            }
            .onAppear {
                keyText = apiKeyStore.key ?? ""
            }
        }
    }

    // MARK: - Data source

    private var dataSourceSection: some View {
        Section {
            Picker("Key type", selection: $apiKeyStore.tier) {
                Text("Demo").tag(APIKeyStore.Tier.demo)
                Text("Pro").tag(APIKeyStore.Tier.pro)
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.theme.surfaceSecondary)

            HStack(spacing: 8) {
                SecureField("Paste your CoinGecko key", text: $keyText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isKeyFocused)
                    .onSubmit { apiKeyStore.save(keyText) }

                if !keyText.isEmpty {
                    Button("Save") {
                        apiKeyStore.save(keyText)
                        isKeyFocused = false
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.brandPrimary)
                    .buttonStyle(.plain)
                }
            }
            .listRowBackground(Color.theme.surfaceSecondary)

            if apiKeyStore.hasKey {
                Button(role: .destructive) {
                    apiKeyStore.remove()
                    keyText = ""
                } label: {
                    Text("Remove key")
                }
                .listRowBackground(Color.theme.surfaceSecondary)
            }
        } header: {
            Text("Data source")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
        } footer: {
            Text(apiKeyStore.hasKey
                 ? "Prices load with your \(apiKeyStore.tier.title.lowercased()) key. It is stored in the device Keychain and only sent to CoinGecko."
                 : "Without a key, prices come from CoinGecko's public tier, which is rate limited and can make refreshes fail. A free key from their dashboard raises that limit.")
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)
        }
    }

    // MARK: - My data

    private var myDataSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.storageSummary)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text("Stored on this device only. Nothing is uploaded, and there is no account.")
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.theme.surfaceSecondary)

            if let csvURL {
                ShareLink(item: csvURL) {
                    Label("Export transactions", systemImage: "square.and.arrow.up")
                }
                .listRowBackground(Color.theme.surfaceSecondary)
            }

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("Delete all transactions", systemImage: "trash")
            }
            .disabled(vm.transactions.isEmpty)
            .listRowBackground(Color.theme.surfaceSecondary)
        } header: {
            Text("My data")
                .font(.system(size: 13))
                .foregroundColor(Color.theme.textSecondary)
        } footer: {
            Text("Deleting the app also deletes this data, so export a copy if you want a backup.")
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)
        }
        .onChange(of: vm.transactions) { _, _ in
            csvURL = vm.transactions.isEmpty ? nil : vm.makeCSVFile()
        }
        .onAppear {
            csvURL = vm.transactions.isEmpty ? nil : vm.makeCSVFile()
        }
        .confirmationDialog(
            "Delete all transactions?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete all", role: .destructive) {
                vm.resetPortfolio()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your holdings and history are removed from this device. This cannot be undone.")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            vm: SettingsViewModel(
                portfolioDataService: PortfolioDataServiceImpl(),
                watchlistStore: WatchlistStore()
            )
        )
        .environmentObject(APIKeyStore())
        .preferredColorScheme(.dark)
    }
}
