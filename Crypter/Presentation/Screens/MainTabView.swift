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
                    Label("Markets", systemImage: "chart.line.uptrend.xyaxis")
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
                    Label("Portfolio", systemImage: "wallet.bifold")
                }

            WatchlistView(vm: WatchlistViewModel(cryptoStore: core.cryptoStore))
                .tabItem {
                    Label("Watchlist", systemImage: "star")
                }
        }
        .tint(Color.theme.brandPrimary)
        .onAppear {
            // A translucent dark bar; iOS 26 draws it as floating glass on its own.
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor(Color.theme.surfaceTertiary).withAlphaComponent(0.7)
            appearance.shadowColor = UIColor(Color.theme.borderSubtle)

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
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
            .environmentObject(WatchlistStore())
    }
}
