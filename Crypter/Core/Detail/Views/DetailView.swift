//
//  DetailView.swift
//  Crypter
//
//  Created by Bishalw on 11/14/22.
//

import SwiftUI
import Charts
struct DetailLoadingView: View {
    
    @Binding var coin: CoinModel?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(vm: DetailViewModel(coin: coin, cryptoDataService: CryptoDataServiceImpl(networkingManager: NetworkingManagerImpl())))
            }
        }
    }
}

struct DetailView: View {
    @StateObject var vm: DetailViewModel
   
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
                    CoinImageView(coinImageViewModel: .createProdInstance(coin: vm.coin ))
                        .frame(width: 25, height: 25)
                }
            }
        }
     
    }
}

struct ChartView: View {

    let data: [Double]
    let maxY: Double
    let minY: Double
    let dateFormatter = DateFormatter()
    let lineColor: Color
    let animation = CABasicAnimation(keyPath: "data")
    
    init(coin: CoinModel) {
        
        data = coin.sparklineIn7D?.price ?? []
        maxY = data.max() ?? 0
        minY = data.min() ?? 0
        
        let priceChange = (data.last ?? 0) - (data.first ?? 0)
        lineColor = priceChange > 0 ? Color.theme.green : Color.theme.red
        animation.fromValue = data.first
        animation.toValue = data.last
        animation.duration = 2 // animate over 2 seconds
    }
    
    var body: some View{
        
        if #available(iOS 16, *) {
            Chart {
                ForEach(0..<data.count, id: \.self) { index in
                    
                    LineMark(
                        x: .value("",index),
                        y: .value("",self.data[index])
                    )
                    .foregroundStyle(lineColor.gradient)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("",index),
                        yStart: .value("",minY),
                        yEnd:.value("", data[index])
                    )
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [lineColor,.clear]), startPoint: .top, endPoint: .bottom)).opacity(0.5)
                }
            }
            .chartYScale(domain: (minY)...(maxY))
            .chartXAxis(content: {
                let value = AxisMarkValues.automatic(minimumStride: 7, desiredCount: 7)
                let date = Date()
                let dayInSeconds = Double(60 * 60 * 24)
                AxisMarks(values: value, content: { value in
                    
                        switch value.index {
                        case 0:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 6))))
                        case 1:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 5))))
                        case 2:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 4))))
                        case 3:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 3))))
                        case 4:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - (dayInSeconds * 2))))
                        case 5:
                            AxisValueLabel.init(getDayOfTheWeek(date: Date(timeIntervalSince1970: date.timeIntervalSince1970 - dayInSeconds)))
                        case 6:
                            AxisValueLabel.init(getDayOfTheWeek(date: date))
                        default:
                            AxisValueLabel.init()
                        }
                })
            })
            .frame(height:250)
            
        } else {
            Text("Charts are supported in iOS 16.0. Please update :)")
        }
    }
    
}

extension ChartView {
    func getDayOfTheWeek(date: Date)-> String{
           dateFormatter.dateFormat = "EEE"
           let weekDay = dateFormatter.string(from: date)
           return weekDay
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
