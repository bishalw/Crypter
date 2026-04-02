//
//  HomeStatsView.swift
//  Crypter
//
//

import SwiftUI

struct HomeStatsView: View {
    
    var statistics: [StatisticModel]
    
    var body: some View {
        HStack {
            ForEach(statistics) { stat in
                StatisticView(stat: stat)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(statistics: [])
    }
}
