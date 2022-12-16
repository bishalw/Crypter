//
//  HomeStatsView.swift
//  Crypter
//
//

import SwiftUI

struct HomeStatsView<ViewModel: HomeViewModel>: View {
    
    @ObservedObject var vm: ViewModel
    @Binding var showPortfolio: Bool
    
    var body: some View {
        HStack {
            ForEach(vm.statistics) { stat in
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
            vm: MockHomeViewModel(),
            showPortfolio: .constant(false))
            .environmentObject(dev.homeVM)
    }
}
