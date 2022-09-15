//
//  HomeView.swift
//  Crypter
//
//

import Foundation
import SwiftUI

struct HomeView: View{
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false
    
    
    var body: some View {
        ZStack{
            // background
            Color.theme.background
                .ignoresSafeArea()
            
            // content layer
            
            VStack {
                homeHeader
        
                HomeStatsView(showPortfolio: $showPortfolio)
                
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
                .animation(.none)
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
        List {
            ForEach(vm.allCoins) { coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0 , bottom: 10, trailing: 10))
            }
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
            Text("Coin")
            Spacer()
            if(showPortfolio){
                Text("Holdings")
            }
            Text("Price")
                .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
        }
    }
}

struct Previews_HomeView_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
