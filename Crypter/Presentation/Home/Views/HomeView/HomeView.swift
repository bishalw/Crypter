//
//  HomeView.swift
//  Crypter
//
//

import Foundation
import SwiftUI

struct HomeView<ViewModel: HomeViewModel>: View{
    @StateObject var vm: ViewModel
    @State private var isPortfolioShown: Bool = false // animate right
    @State private var showPortfolioViewSheet: Bool = false // new sheet
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    @State private var showSettingsView: Bool = false
    
    var body: some View {
        
        NavigationStack {
            ZStack{
                // background
                Color.theme.background
                    .ignoresSafeArea()
                    .sheet(isPresented: $showPortfolioViewSheet, content: {
                        PortfolioView(vm: vm)
                            .environmentObject(vm)
                        
                    })
                
                // content layer
                
                VStack {
                    HomeHeaderView(
                        isPortfolioShown: isPortfolioShown,
                        onAddButtonTapped: {
                            showPortfolioViewSheet.toggle()
                        },
                        onInfoButtonTapped: {
                            showSettingsView.toggle()
                        },
                        onTogglePortfolio: { isShown in
                            withAnimation(.spring()) {
                                isPortfolioShown.toggle()
                            }
                        }
                    )
                    if isPortfolioShown {
                        StatisticView(stat: StatisticModel(title: "Total Holding", value: vm.myTotalHoldingDisplayString))
                    } else {
                        HomeStatsView(statistics: vm.statistics,
                                      showPortfolio: $isPortfolioShown)
                    }
                    
                    SearchBarView(searchText: $vm.searchText)
                    
                    ColumnTitleView(sortOption: $vm.sortOption, isPortfolioViewShown: isPortfolioShown)
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                        .padding(.horizontal)
                    
                    if isPortfolioShown{
                        ZStack(alignment: .top) {
                            if vm.portfolioCoins.isEmpty && vm.searchText.isEmpty {
                                Text("You havne't added any coins to your portfolio yet. Click on the + button to get started! 🧐 ")
                                    .font(.callout)
                                    .foregroundColor(Color.theme.accent)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                                
                            } else {
                                List {
                                    ForEach(vm.portfolioCoins) { coin in
                                        CoinRowView(coin: coin, showHoldingsColumn: true)
                                            .listRowInsets(.init(top: 10, leading: 0 , bottom: 10, trailing: 10))
                                            .onTapGesture {
                                                segue(coin: coin)
                                            }
                                    }
                                }
                                .listRowBackground(Color.theme.background)
                                .listStyle(PlainListStyle())
                                
                            }
                        }.transition(.move(edge: .leading))
                        
                        
                    } else {
                        allCoinsList
                            .transition(.move(edge: .trailing))
                    }
                    Spacer(minLength: 0)
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .sheet(isPresented: $showSettingsView, content: {
                    SettingsView()
                    
                })
            }
            .navigationDestination(isPresented: $showDetailView) {
                DetailLoadingView(coin: $selectedCoin)
            }
        }
        
    }
    
}

struct HomeView_Previews: PreviewProvider{
    static var previews: some View{
        NavigationView {
            HomeView(vm: MockHomeViewModel())
                .navigationBarHidden(true)
        }
        
    }
}

extension HomeView{
    
    
    private var allCoinsList: some View {
        List{
            ForEach(vm.allCoins) { coin in
                NavigationLink(destination: DetailLoadingView(coin: .constant(coin))) {
                    CoinRowView(coin: coin, showHoldingsColumn: false)
                        .onTapGesture {
                            segue(coin: coin)
                        }
                }
            }
            
        }
        .listStyle(PlainListStyle())
        .refreshable {
            vm.reloadData()
        }
    }
    
    private func segue(coin: CoinModel) {
        selectedCoin = coin
        showDetailView.toggle()
    }
}


