//
//  CrypterApp.swift
//  Crypter
//
//

import SwiftUI

@main
struct CrypterApp: App {
    
    @StateObject private var vm = HomeViewModel(coinDataService: .init(networkingManager: RealNetworkingManager()), marketDataService: .init(networkingManager: RealNetworkingManager()))
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            
        }
    }
    
}
