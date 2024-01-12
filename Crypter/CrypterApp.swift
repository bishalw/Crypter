//
//  CrypterApp.swift
//  Crypter
//
//

import SwiftUI

@main
struct CrypterApp: App {

    let prodVm = HomeViewModelImpl(cryptoDataService: CryptoDataServiceImpl(networkingManager: NetworkingManagerImpl()))
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]                               
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(vm: prodVm)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}


