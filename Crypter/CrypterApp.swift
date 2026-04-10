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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
        let uiColor = UIColor(Color.theme.brandPrimary)
        appearance.largeTitleTextAttributes = [
            .foregroundColor: uiColor,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold).withDesign(.rounded)!
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: uiColor,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold).withDesign(.rounded)!
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = uiColor
    }
    
    var body: some Scene {
        WindowGroup {
                MainTabView()
                    .environmentObject(core)
        }
    }
    
}


