//
//  HomeStatsView.swift
//  Crypter
//
//

import SwiftUI

struct HomeStatsView: View {
    
    var statistics: [StatisticModel]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(statistics) { stat in
                StatisticView(stat: stat)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.background)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.theme.secondaryText.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(statistics: [])
    }
}
