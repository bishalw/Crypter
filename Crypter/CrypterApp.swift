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
        let uiColor = UIColor(Color.theme.brandPrimary)
        let titleColor = UIColor(Color.theme.textPrimary)

        let largeTitleFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        let titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: titleColor, .font: titleFont]
        let largeTitleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: titleColor, .font: largeTitleFont]

        // Transparent while the large title is showing
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.titleTextAttributes = titleAttributes
        scrollEdgeAppearance.largeTitleTextAttributes = largeTitleAttributes

        // Solid once content scrolls under the collapsed title, so it stays legible
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(Color.theme.surfaceBackground)
        standardAppearance.shadowColor = UIColor(Color.theme.borderSubtle)
        standardAppearance.titleTextAttributes = titleAttributes
        standardAppearance.largeTitleTextAttributes = largeTitleAttributes

        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
        UINavigationBar.appearance().tintColor = uiColor
    }
    
    var body: some Scene {
        WindowGroup {
                MainTabView()
                    .environmentObject(core)
                    .environmentObject(core.watchlistStore)
                    // The palette is dark-only; keep system controls (search field, keyboard, tab bar) in sync
                    .preferredColorScheme(.dark)
        }
    }
    
}


