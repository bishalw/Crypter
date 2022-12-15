//
//  HomeView.swift
//  Crypter
//
//

import Foundation
import SwiftUI

struct HomeView: View{
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var isPortfolioShown: Bool = false // animate right
    @State private var showPortfolioViewSheet: Bool = false // new sheet
    
    @State private var selectedCoin: CoinModel? = nil
    @State private var showDetailView: Bool = false
    @State private var showSettingsView: Bool = false
    
    var body: some View {
        ZStack{
            // background
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioViewSheet, content: {
                    PortfolioView()
                    .environmentObject(vm)
                        
                })

            // content layer
            
            VStack {
                homeHeader
               if isPortfolioShown {
                   StatisticView(stat: StatisticModel(title: "Total Holding", value: vm.myTotalHoldingDisplayString))
                } else {
                    HomeStatsView(showPortfolio: $isPortfolioShown)
                }
                
                SearchBarView(searchText: $vm.searchText)
                
                columnTitles
                
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
                                portfolioCoinsList
                                    
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
        .background(
            NavigationLink(
                destination: DetailLoadingView(coin: $selectedCoin),
                isActive: $showDetailView,
                label: {EmptyView()})
            )
    }

}

struct HomeView_Previews: PreviewProvider{
    static var previews: some View{
        NavigationView {
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
        .previewInterfaceOrientation(.portraitUpsideDown)
    }
}

extension HomeView{
    
    private var homeHeader: some View {
        HStack{
            
            CircleButtonView(iconName: isPortfolioShown ? "plus" : "info")
                .animation(.none, value: isPortfolioShown)
                .onTapGesture {
                    if isPortfolioShown {
                        showPortfolioViewSheet.toggle()
                    } else {
                        showSettingsView.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $isPortfolioShown)
                )
            Spacer()
            Text(isPortfolioShown ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: isPortfolioShown ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        isPortfolioShown.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
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
            
        }.refreshable {
            vm.reloadData()
        }
        .listStyle(PlainListStyle())
    }
    
    private func segue(coin: CoinModel) {
        selectedCoin = coin
        showDetailView.toggle()
    }
    
    private var portfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0 , bottom: 10, trailing: 10))
                    .onTapGesture {
                        segue(coin: coin)
                    }
            }
        }
        
        
        .listStyle(PlainListStyle())
    }
    
    private var columnTitles: some View {
        HStack{
            HStack(spacing: 4){
                Text("Coin")
                Image(systemName: "chevron.down")
                    .opacity( (vm.sortOption == .rank || vm.sortOption == .rankReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .rank ? 0 : 180))
            }
            .onTapGesture {
                withAnimation(.default){
                    if vm.sortOption == .rank {
                        vm.sortOption = .rankReversed
                    } else {
                        vm.sortOption = .rank
                    }
                }
               // vm.sortOption = vm.sortOption == .rank ? .rankReversed : .rank
                
            }
            Spacer()
            HStack(spacing: 4){
                Text("Price")
                Image(systemName: "chevron.down")
                    .opacity( (vm.sortOption == .price  || vm.sortOption == .priceReversed) ? 1.0 : 0.0)
                    .rotationEffect(Angle(degrees: vm.sortOption == .price ? 0 : 180))
            }
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            .onTapGesture {
                withAnimation(.default){
                    vm.sortOption = vm.sortOption == .price ? .priceReversed : .price
                }
            }
            if(isPortfolioShown){
                HStack(spacing: 4){
                    Text("Holdings")
                    Image(systemName: "chevron.down")
                        .opacity( (vm.sortOption == .holdings  || vm.sortOption == .holdingsReversed) ? 1.0 : 0.0)
                        .rotationEffect(Angle(degrees: vm.sortOption == .holdings ? 0 : 180))
                }
                .onTapGesture {
                    withAnimation(.default){
                        vm.sortOption = vm.sortOption == .holdings ? .holdingsReversed : .holdings
                    }
                }
            }
            
        }
    }
}

struct Previews_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
