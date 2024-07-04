//
//  MainView.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var core: Core
    
    var body: some View {
        NavigationStack {
            TabView {
                HomeView(vm: HomeViewModelImpl(cryptoStore: core.cryptoStore))
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                PortfolioView(vm: PortfolioViewModelImpl(cryptoStore: core.cryptoStore, portfolioDataService: PortfolioDataServiceImpl()))
                    .tabItem {
                        Label("Portfolio", systemImage: "creditcard")
                    }
            }
        }
      
    }
}
