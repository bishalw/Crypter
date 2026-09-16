//
//  WatchlistView.swift
//  Crypter
//

import Foundation
import SwiftUI
import Combine

final class WatchlistViewModel: ObservableObject {
    @Published private(set) var allCoins: [CoinModel] = []

    private let cryptoStore: CryptoStore
    private var cancellables = Set<AnyCancellable>()

    init(cryptoStore: CryptoStore) {
        self.cryptoStore = cryptoStore
        bind()
    }

    func reloadData() {
        cryptoStore.fetchAllCoins()
    }

    private func bind() {
        cryptoStore.coins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coins in
                self?.allCoins = coins ?? []
            }
            .store(in: &cancellables)
    }
}

struct WatchlistView: View {
    @EnvironmentObject var core: Core
    @EnvironmentObject var watchlist: WatchlistStore
    @StateObject var vm: WatchlistViewModel

    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false

    private var coins: [CoinModel] {
        watchlist.coins(from: vm.allCoins)
    }

    var body: some View {
        NavigationStack {
            Group {
                if watchlist.coinIDs.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Color.theme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitleIfAvailable(subtitle)
            .toolbar {
                if !watchlist.coinIDs.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                            .foregroundColor(Color.theme.brandPrimary)
                    }
                }
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

    private var subtitle: String {
        let count = watchlist.coinIDs.count
        return count == 1 ? "1 coin" : "\(count) coins"
    }

    private var list: some View {
        List {
            ForEach(coins) { coin in
                Button {
                    selectedCoin = coin
                    showDetailView = true
                } label: {
                    CoinRowView(coin: coin, showHoldingsColumn: false, showSparkline: true)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .listRowBackground(Color.theme.surfaceBackground)
                .listRowSeparatorTint(Color.theme.borderSubtle)
            }
            .onDelete { offsets in
                watchlist.removeAll(atOffsets: offsets)
            }
            .onMove { source, destination in
                watchlist.move(fromOffsets: source, toOffset: destination)
            }

            footer
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0)
        .scrollContentBackground(.hidden)
    }

    private var footer: some View {
        Text("Swipe a coin to remove it · Edit to reorder")
            .font(.system(size: 11))
            .foregroundColor(Color.theme.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .listRowBackground(Color.theme.surfaceBackground)
            .listRowSeparator(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.theme.brandSoft)
                    .frame(width: 140, height: 140)

                Image(systemName: "star")
                    .font(.system(size: 56))
                    .foregroundColor(Color.theme.brandPrimary)
            }

            VStack(spacing: 8) {
                Text("No coins watched yet")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)

                Text("Open a coin and tap the star, or press and hold it in Markets, to follow its price here.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView(vm: WatchlistViewModel(cryptoStore: MockCryptoStore()))
            .environmentObject(Core.preview)
            .environmentObject(WatchlistStore())
    }
}
