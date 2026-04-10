//
//  CryptoStore.swift
//  Crypter
//

import Foundation
import Combine

protocol CryptoStore {
    var coins: CurrentValueSubject<[CoinModel]?, Never> { get set }
    var coinDetails: CurrentValueSubject<CoinDetailModel?, Never> { get set }
    var globalDetails: CurrentValueSubject<MarketDataModel?, Never> { get set }
    var chartPoints: CurrentValueSubject<[ChartPoint], Never> { get set }
    
    func fetchAllCoins()
    func fetchCoinDetails(coin: CoinModel)
    func fetchGlobalData()
    func fetchMarketChart(coin: CoinModel, range: ChartTimeRange)
}

class CryptoStoreImpl: CryptoStore {
    
    var coins = CurrentValueSubject<[CoinModel]?, Never>(nil)
    var coinDetails = CurrentValueSubject<CoinDetailModel?, Never>(nil)
    var globalDetails = CurrentValueSubject<MarketDataModel?, Never>(nil)
    var chartPoints = CurrentValueSubject<[ChartPoint], Never>([])
    
    private var historicalCache: [String: [String: [ChartPoint]]] = [:]
    private let repository: CryptoRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CryptoRepository) {
        self.repository = repository
    }
    
    func fetchAllCoins() {
        repository.fetchAllCoins()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] coins in
                self?.coins.send(coins)
            })
            .store(in: &cancellables)
    }
    
    func fetchCoinDetails(coin: CoinModel) {
        repository.fetchCoinDetail(coin: coin)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] details in
                self?.coinDetails.send(details)
            })
            .store(in: &cancellables)
    }
    
    func fetchGlobalData() {
        repository.fetchGlobalData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] data in
                self?.globalDetails.send(data)
            })
            .store(in: &cancellables)
    }
    
    func fetchMarketChart(coin: CoinModel, range: ChartTimeRange) {
        let days = mapRangeToDays(range)
        
        // 1. Immediate Load from Sparkline (for 7D)
        if range == .week, let sparkline = coin.price, !sparkline.isEmpty {
            chartPoints.send(mapSparklineToPoints(sparkline))
        }
        
        // 2. Check Cache
        if let cached = historicalCache[coin.id]?[days] {
            chartPoints.send(cached)
            return
        }
        
        // 3. Remote Fetch
        repository.fetchMarketChart(coinID: coin.id, days: days)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] points in
                guard let self = self else { return }
                if self.historicalCache[coin.id] == nil { self.historicalCache[coin.id] = [:] }
                self.historicalCache[coin.id]?[days] = points
                self.chartPoints.send(points)
            })
            .store(in: &cancellables)
    }
    
    private func mapRangeToDays(_ range: ChartTimeRange) -> String {
        switch range {
        case .day: return "1"
        case .week: return "7"
        case .month: return "30"
        case .year: return "365"
        case .all: return "max"
        }
    }
    
    private func mapSparklineToPoints(_ prices: [Double]) -> [ChartPoint] {
        let now = Date()
        let count = prices.count
        return prices.enumerated().map { index, price in
            let offset = Double(count - 1 - index) * -3600
            return ChartPoint(date: now.addingTimeInterval(offset), price: price)
        }
    }
}
