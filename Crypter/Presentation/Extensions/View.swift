//
//  View.swift
//  Crypter
//

import SwiftUI

extension View {
    /// Collapses the search field into a toolbar button on iOS 26+, so the
    /// navigation title and actions stay visible until search is tapped.
    @ViewBuilder
    func minimizedSearchToolbarIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            searchToolbarBehavior(.minimize)
        } else {
            self
        }
    }

    @ViewBuilder
    func navigationSubtitleIfAvailable(_ subtitle: String) -> some View {
        if #available(iOS 26.0, *) {
            navigationSubtitle(subtitle)
        } else {
            self
        }
    }
}
