//
//  DetailView.swift
//  Crypter
//
//

import SwiftUI
import Charts

struct DetailLoadingView: View {
    @EnvironmentObject var core: Core
     @Binding var coin: CoinModel?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(vm: DetailViewModelImpl(coin: coin, cryptoStore: core.getCryptoStore))
            }
        }
    }
}

struct DetailView<ViewModel>: View where ViewModel: DetailViewModel{
    @StateObject var vm: ViewModel
    @EnvironmentObject var core: Core
    @State private var showFullDescription: Bool = false
    

    private let spacing: CGFloat = 20
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView{
            VStack(spacing: 10) {
                CoinChartView
                OverwiewTitle
                Divider()
                OverviewGrid
                AdditionalTitle
                Divider()
                AdditionalGrid
                OverViewDescription
                WebsiteSection
                .accentColor(.blue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                
            }
            .padding()
        }
        .navigationTitle(vm.coin.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                HStack{
                    Spacer()
                    Text(vm.coin.symbol.uppercased())
                        .font(.headline)
                        .foregroundColor(Color.theme.secondaryText)
                    CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.getCoinImageRepository, coin: vm.coin))
                        .frame(width: 25, height: 25)
                }
            }
        }
     
    }
}


extension DetailView {
    private var CoinChartView: some View {
        VStack(alignment: .trailing, spacing: 0){
            ChartView(coin: vm.coin)
        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
    }
    private var OverwiewTitle: some View {
        Text("Overview")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    private var AdditionalTitle: some View {
        Text("Additional Details")
            .font(.title)
            .bold()
            .foregroundColor(Color.theme.accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var OverViewDescription: some View {
        ZStack {
            if let coinDescription = vm.coinDescription,
               !coinDescription.isEmpty {
                VStack(alignment: .leading){
                    Text(coinDescription)
                        .lineLimit(showFullDescription ? nil : 3)
                        .font(.callout)
                        .foregroundColor(Color.theme.secondaryText)
                        .onTapGesture {
                            withAnimation(.linear){
                                showFullDescription.toggle()
                            }
                        }
                    Button {
                        withAnimation(.linear){
                            showFullDescription.toggle()
                        }
                    } label: {
                        Text(showFullDescription ? "Less" : "Read more...")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.vertical, 4)
                    }.accentColor(.blue)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var OverviewGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: [],
            content: {
                ForEach(vm.overViewStatistics) { stat in
                    StatisticView(stat: stat)
                }
            })
    }
    private var AdditionalGrid: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            pinnedViews: [],
            content: {
                ForEach(vm.additionalStatistics) { stat in
                    StatisticView(stat: stat)
                }
            })
    }
    private var WebsiteSection: some View {
        VStack(alignment: .leading){
            if let websiteString = vm.websiteURL,
               let url = URL(string: websiteString){
                Link("Official Website", destination: url).padding([.top,.bottom], 4)
            }
            Spacer()
            if let redditString = vm.redditURL,
                let url = URL(string: redditString) {
                Link("Reddit", destination: url).padding([.top,.bottom], 4)
            }
            Spacer()
            
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Detail Preview")
    }
}
