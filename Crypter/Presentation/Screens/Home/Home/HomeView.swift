//
//  HomeView.swift
//  Crypter
//

import Foundation
import SwiftUI

struct HomeView<ViewModel>: View where ViewModel: HomeViewModel {
    @EnvironmentObject var core: Core
    @StateObject var vm: ViewModel
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var editorCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
                HomeStatsView(statistics: vm.statistics)
                
                SearchBarView(searchText: $vm.searchText)
                
                ColumnTitleView(sortOption: $vm.sortOption, isPortfolioViewShown: false)
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
                    .padding(.horizontal)
                
                allCoinsList
                
                Spacer(minLength: 0)
            }
            .sheet(item: $editorCoin) { coin in
                PortfolioEditorView(
                    vm: PortfolioEditorViewModel(
                        cryptoStore: core.cryptoStore,
                        portfolioDataService: core.portfolioDataService,
                        preselectedCoinID: coin.id
                    )
                )
                .environmentObject(core)
            }
            .navigationTitle("Prices")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showDetailView) {
                if let coin = selectedCoin {
                    DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.cryptoStore))
                }
            }
        }
    }
    
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .onTapGesture {
                        selectedCoin = coin
                        showDetailView.toggle()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            editorCoin = coin
                        } label: {
                            Label("Add to Portfolio", systemImage: "plus.circle")
                        }
                        .tint(Color.theme.green)
                    }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            vm.reloadData()
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(vm: PreviewHomeViewModel())
            .environmentObject(Core.preview)
    }
}
