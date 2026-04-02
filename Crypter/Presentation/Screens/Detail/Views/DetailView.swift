//
//  DetailView.swift
//  Crypter
//
//

import SwiftUI
import Charts


struct DetailView<ViewModel>: View where ViewModel: DetailViewModel {
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
                ChartView(coin: vm.coin)
                Title(withTitle: "Overview")
                Divider()
                OverviewGrid
                Title(withTitle: "Additional Details")
                Divider()
                AdditionalGrid
                OverViewDescription
                LinkView(for: vm.websiteURL, withTitle: "Official Website")
                Spacer()
                LinkView(for: vm.redditURL, withTitle: "Reddit")
                Spacer()
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
                    toolbarContent()
                }
            }
        }
    }
}


extension DetailView {
    
    @ViewBuilder
    private func Title(withTitle title: String) -> some View {
        Text(title)
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
    
    @ViewBuilder
    private func LinkView(for urlString: String?, withTitle title: String) -> some View {
        if let urlString = urlString, let url = URL(string: urlString) {
            Link(title, destination: url)
                .padding([.top, .bottom], 4)
        }
    }
    
    @ViewBuilder
    private func toolbarContent() -> some View {
        Text(vm.coin.symbol.uppercased())
            .font(.headline)
            .foregroundColor(Color.theme.secondaryText)
        CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: vm.coin))
            .frame(width: 25, height: 25)
    }
}
struct StatisticsGrid<T: Identifiable>: View {
    var items: [T]
    var columns: [GridItem]
    var spacing: CGFloat
    var content: (T) -> AnyView

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
            ForEach(items) { item in
                content(item)
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Detail Preview")
    }
}
