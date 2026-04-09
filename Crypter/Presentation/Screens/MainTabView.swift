//
//  MainView.swift
//  Crypter
//
//  Created by Bishalw on 6/22/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var core: Core
    private let homeTabOverride: AnyView?
    private let portfolioTabOverride: AnyView?

    init(
        homeTabOverride: AnyView? = nil,
        portfolioTabOverride: AnyView? = nil
    ) {
        self.homeTabOverride = homeTabOverride
        self.portfolioTabOverride = portfolioTabOverride
    }
    
    var body: some View {
        TabView {
            Group {
                if let homeTabOverride {
                    homeTabOverride
                } else {
                    HomeView(vm: HomeViewModelImpl(
                        cryptoStore: core.cryptoStore,
                        portfolioDataService: core.portfolioDataService
                    ))
                }
            }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Group {
                if let portfolioTabOverride {
                    portfolioTabOverride
                } else {
                    PortfolioView(vm: PortfolioViewModelImpl(
                        cryptoStore: core.cryptoStore,
                        portfolioDataService: core.portfolioDataService
                    ))
                }
            }
                .tabItem {
                    Label("Portfolio", systemImage: "creditcard")
                }
        }.onAppear {
            let appearance = UITabBarAppearance()
              appearance.configureWithOpaqueBackground()
              UITabBar.appearance().standardAppearance = appearance
              
              if #available(iOS 15.0, *) {
                  UITabBar.appearance().scrollEdgeAppearance = appearance
              }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(
            homeTabOverride: AnyView(HomeView(vm: PreviewHomeViewModel())),
            portfolioTabOverride: AnyView(PortfolioView(vm: PreviewPortfolioViewModel()))
        )
            .environmentObject(Core.preview)
    }
}
