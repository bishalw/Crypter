//
//  CrypterApp.swift
//  Crypter
//
//

import SwiftUI

@main
struct CrypterApp: App {
    
    ///Depdency Container
    @StateObject var core = Core()
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]                               
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(vm: HomeViewModelImpl(cryptoStore: core.getCryptoStore))
                    .navigationBarHidden(true)
                    .environmentObject(core)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}


