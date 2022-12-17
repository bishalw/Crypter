//
//  HomeStatsView.swift
//  Crypter
//
//

import SwiftUI

struct HomeStatsView: View {
    
    var statistics: [StatisticModel]
    @Binding var showPortfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(statistics) { stat in
                StatisticView(stat: stat)
                    .frame(width: UIScreen.main.bounds.width/3)
            }
        }
        .frame(width: UIScreen.main.bounds.width, alignment: showPortfolio ? .trailing : .leading)
            
    }
}

struct HomeStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeStatsView(
            statistics: [],
            showPortfolio: .constant(false))
    }
}
