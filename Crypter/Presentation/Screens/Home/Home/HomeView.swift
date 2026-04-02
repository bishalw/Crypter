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
    @State private var showPortfolioViewSheet: Bool = false
    @State private var showDetailView: Bool = false
    @State private var showSettingsView: Bool = false
    
    var body: some View {
        NavigationStack {
            NavigationView {
                VStack {
                    
                    HomeStatsView(statistics: vm.statistics, showPortfolio: .constant(false))
                    
                    SearchBarView(searchText: $vm.searchText)
                    
                    ColumnTitleView(sortOption: $vm.sortOption, isPortfolioViewShown: false)
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                        .padding(.horizontal)
                    
                    allCoinsList
                    
                    Spacer(minLength: 0)
                }
                .sheet(isPresented: $showPortfolioViewSheet) {
                    PortfolioCoinSelectionSheet(vm: vm)
                }
                .sheet(isPresented: $showSettingsView) {
                    SettingsView()
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
        
    }
    
    private var allCoinsList: some View {
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .onTapGesture {
                        selectedCoin = coin
                        showDetailView.toggle()
                    }
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            vm.reloadData()
        }
    }
}


struct HomeView_Previews: PreviewProvider{
    static var previews: some View{
        NavigationView {
            EmptyView()
                .navigationBarHidden(true)
        }

    }
}

//                    HomeHeaderView(
//                        isPortfolioShown: false,
//                        onAddButtonTapped: {
//                            showPortfolioViewSheet.toggle()
//                        },
//                        onInfoButtonTapped: {
//                            showSettingsView.toggle()
//                        },
//                        onTogglePortfolio: { _ in }
//                    )
