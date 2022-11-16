//
//  HomeView.swift
//  Crypter
//
//

import Foundation
import SwiftUI

struct HomeView: View{
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false // animate right
    @State private var showPortfolioViewSheet: Bool = false // new sheet
    
    
    var body: some View {
        ZStack{
            // background
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioViewSheet, content: {
                    PortfolioView(dismiss: {
                        showPortfolioViewSheet.toggle()
                    })
                        .environmentObject(vm)
                })

            // content layer
            
            VStack {
                homeHeader
               if showPortfolio {
                   StatisticView(stat: StatisticModel(title: "Total Holding", value: vm.myTotalHoldingDisplayString))
                } else {
                    HomeStatsView(showPortfolio: $showPortfolio)
                }
                
                SearchBarView(searchText: $vm.searchText)
                
                columnTitles
                
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .padding(.horizontal)
                
                    if showPortfolio{
                        portfolioCoinsList
                            .transition(.move(edge: .leading))
                        
                    } else {
                        allCoinsList
                            .transition(.move(edge: .trailing))
                        
                    }
                
              
                Spacer(minLength: 0)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
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
            
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: showPortfolio)
                .onTapGesture {
                    if showPortfolio {
                        showPortfolioViewSheet.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )
            Spacer()
            Text(showPortfolio ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        showPortfolio.toggle()
                    }
                }
        }
        .padding(.horizontal)
    }
    
    private var allCoinsList: some View {
        List{
            ForEach(vm.allCoins) { coin in
                NavigationLink(
                    destination: DetailView(coin: coin),
                    label: {
                        CoinRowView(coin: coin, showHoldingsColumn: false)
                            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
                    })
            }
            
        }.refreshable {
            vm.reloadData()
        }
        .listStyle(PlainListStyle())
    }
    
    private var portfolioCoinsList: some View {
        List {
            ForEach(vm.portfolioCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0 , bottom: 10, trailing: 10))
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
            if(showPortfolio){
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
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
