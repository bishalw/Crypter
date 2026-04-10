//
//  HomeStatsView.swift
//  Crypter
//
//

import SwiftUI

struct HomeStatsView: View {
    
    var statistics: [StatisticModel]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(statistics) { stat in
                StatisticView(stat: stat)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.theme.borderSubtle, lineWidth: 1)
                )
        )
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(statistics: [])
    }
}
