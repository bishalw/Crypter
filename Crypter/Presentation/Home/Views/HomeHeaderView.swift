//
//  HomeHeaderView.swift
//  Crypter
//
//

import SwiftUI

struct HomeHeaderView: View {
    let isPortfolioShown: Bool
    var onAddButtonTapped: () -> Void
    var onInfoButtonTapped: () -> Void
    var onTogglePortfolio: (Bool) -> Void

    var body: some View {
        HStack {
            CircleButtonView(iconName: isPortfolioShown ? "settings" : "info")
                .animation(.none, value: isPortfolioShown)
                .onTapGesture {
                    isPortfolioShown ? onAddButtonTapped() : onInfoButtonTapped()
                }
                .background(
                    CircleButtonAnimationView(animate: .constant(isPortfolioShown))
                )
            Spacer()
            Text(isPortfolioShown ? "Portfolio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(Color.theme.accent)
                .animation(.none)
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: isPortfolioShown ? 180 : 0))
                .onTapGesture {
                    onTogglePortfolio(isPortfolioShown)
                }
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeHeaderView(isPortfolioShown: true, onAddButtonTapped: {
        
    }, onInfoButtonTapped: {
        
    }, onTogglePortfolio: {_ in 
        
    })
}
