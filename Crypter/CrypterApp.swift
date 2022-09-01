//
//  CrypterApp.swift
//  Crypter
//
//  Created by Bishalw on 7/14/22.
//

import SwiftUI

@main
struct CrypterApp: App {
    
    @StateObject private var vm = HomeViewModel(coinDataService: .init(networkingManager: RealNetworkingManager()))
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
            // all child of homeview has access to vm
            .environmentObject(vm)
        }
    }
    
}
