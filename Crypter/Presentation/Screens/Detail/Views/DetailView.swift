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
    @State private var isShowingHoldings: Bool = true
    
    private let spacing: CGFloat = 20
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                priceHeader
                
                ChartView(coin: vm.coin)
                    .padding(.top, -8)
                
                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle("Overview")
                    overviewCard
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    sectionTitle("Additional Details")
                    additionalCard
                }
                
                if let coinDescription = vm.coinDescription, !coinDescription.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("About \(vm.coin.name)")
                        descriptionCard(description: coinDescription)
                    }
                }
                
                linkSection
            }
            .padding()
        }
        .navigationTitle(vm.coin.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                toolbarContent()
            }
        }
    }
}

extension DetailView {
    
    private var priceHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            let hasHoldings = (vm.coin.currentHoldings ?? 0) > 0
            let totalValue = (vm.coin.currentHoldings ?? 0) * vm.coin.currentPrice
            
            VStack(alignment: .leading, spacing: 2) {
                if isShowingHoldings && hasHoldings {
                    Text(totalValue.asCurrencyWith2Decimals())
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("\(vm.coin.currentPrice.asCurrencyWith6Decimals()) per \(vm.coin.symbol.uppercased())")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                } else {
                    Text(vm.coin.currentPrice.asCurrencyWith6Decimals())
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("Market Price")
                        .font(.caption)
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            .foregroundColor(Color.theme.accent)
            .contentTransition(.numericText())
            .onTapGesture {
                if hasHoldings {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        isShowingHoldings.toggle()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            
            HStack(spacing: 4) {
                Image(systemName: (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? "triangle.fill" : "triangle.fill")
                    .font(.caption2)
                    .rotationEffect(Angle(degrees: (vm.coin.priceChangePercentage24H ?? 0) >= 0 ? 0 : 180))
                
                Text(vm.coin.priceChangePercentage24H?.asPercentString() ?? "0.00%")
                    .font(.callout)
                    .fontWeight(.semibold)
                
                Text("24h")
                    .font(.caption)
                    .foregroundColor(Color.theme.secondaryText)
            }
            .foregroundColor((vm.coin.priceChangePercentage24H ?? 0) >= 0 ? Color.theme.green : Color.theme.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3)
            .bold()
            .foregroundColor(Color.theme.accent)
    }
    
    private var overviewCard: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            content: {
                ForEach(vm.overViewStatistics) { stat in
                    StatisticView(stat: stat)
                }
            })
            .padding()
            .background(cardBackground)
    }
    
    private var additionalCard: some View {
        LazyVGrid(
            columns: columns,
            alignment: .leading,
            spacing: spacing,
            content: {
                ForEach(vm.additionalStatistics) { stat in
                    StatisticView(stat: stat)
                }
            })
            .padding()
            .background(cardBackground)
    }
    
    private func descriptionCard(description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(description)
                .lineLimit(showFullDescription ? nil : 4)
                .font(.subheadline)
                .foregroundColor(Color.theme.secondaryText)
            
            Button {
                withAnimation(.spring()) {
                    showFullDescription.toggle()
                }
            } label: {
                Text(showFullDescription ? "Show Less" : "Read More")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.vertical, 4)
            }
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(cardBackground)
    }
    
    private var linkSection: some View {
        VStack(spacing: 12) {
            if let websiteURL = vm.websiteURL {
                LinkView(for: websiteURL, title: "Official Website", icon: "safari")
            }
            if let redditURL = vm.redditURL {
                LinkView(for: redditURL, title: "Reddit Community", icon: "bubble.left.and.bubble.right")
            }
        }
    }
    
    @ViewBuilder
    private func LinkView(for urlString: String, title: String, icon: String) -> some View {
        if let url = URL(string: urlString) {
            Link(destination: url) {
                HStack {
                    Image(systemName: icon)
                    Text(title)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                }
                .padding()
                .background(cardBackground)
                .foregroundColor(.blue)
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.theme.background)
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.theme.secondaryText.opacity(0.1), lineWidth: 1)
            )
    }
    
    private func toolbarContent() -> some View {
        HStack(spacing: 8) {
            Text(vm.coin.symbol.uppercased())
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
            
            CoinImageView(vm: CoinImageViewModelImpl(coinImageRepository: core.coinImageRepository, coin: vm.coin))
                .frame(width: 28, height: 28)
                .clipShape(Circle())
        }
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
        NavigationStack {
            DetailView(vm: PreviewDetailViewModel())
                .environmentObject(Core.preview)
        }
    }
}
