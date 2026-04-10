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
        
        let largeTitleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        // Safely apply rounded design if available
        let roundedLargeTitleFont = largeTitleFont.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: 0) } ?? largeTitleFont
        let roundedTitleFont = titleFont.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: 0) } ?? titleFont

        appearance.largeTitleTextAttributes = [
            .foregroundColor: uiColor,
            .font: roundedLargeTitleFont
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: uiColor,
            .font: roundedTitleFont
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


