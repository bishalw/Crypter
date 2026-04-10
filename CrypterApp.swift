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
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.brandPrimary)]                               
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.brandPrimary)]
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


