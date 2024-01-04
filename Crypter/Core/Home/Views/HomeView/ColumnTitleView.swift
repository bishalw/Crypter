//
//  ColumnTitleView.swift
//  Crypter
//
//  Created by Bishalw on 1/4/24.
//

import SwiftUI
struct ColumnTitleView: View {
    @Binding var sortOption: SortOption
    let isPortfolioViewShown: Bool

    var body: some View {
        HStack {
            // Coin column title
            SortButton(title: "Coin", currentSortOption: $sortOption, activeOptions: [.rank, .rankReversed])
            Spacer()
            // Price column title
            SortButton(title: "Price", currentSortOption: $sortOption, activeOptions: [.price, .priceReversed])
            .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            // Holdings column title (shown only for portfolio view)
            if isPortfolioViewShown {
                SortButton(title: "Holdings", currentSortOption: $sortOption, activeOptions: [.holdings, .holdingsReversed])
            }
        }
    }
}

struct SortButton: View {
    let title: String
    @Binding var currentSortOption: SortOption
    let activeOptions: [SortOption]
    
    var body: some View {
        Button(action: toggleSort) {
            HStack(spacing: 4) {
                Text(title)
                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isActiveSortOption && isReversed ? 180 : 0))
                    .opacity(isActiveSortOption ? 1.0 : 0.0)
            }
        }
    }
    
    var isActiveSortOption: Bool {
        activeOptions.contains(currentSortOption)
    }
    
    var isReversed: Bool {
        switch currentSortOption {
        case .rankReversed, .priceReversed, .holdingsReversed:
            return true
        default:
            return false
        }
    }
    
    private func toggleSort() {
        // Logic to toggle between the active sort options
        if let currentIndex = activeOptions.firstIndex(of: currentSortOption),
           currentIndex < activeOptions.count - 1 {
            currentSortOption = activeOptions[currentIndex + 1]
        } else {
            currentSortOption = activeOptions.first ?? currentSortOption
        }
    }
}

#Preview {
    ColumnTitleView(sortOption: .constant(.holdings), isPortfolioViewShown: true)
}
