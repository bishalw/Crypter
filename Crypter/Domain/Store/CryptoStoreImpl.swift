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
    var chartErrorMessage: CurrentValueSubject<String?, Never> { get set }
    
    func fetchAllCoins()
    func fetchCoinDetails(coin: CoinModel)
    func fetchGlobalData()
    func fetchMarketChart(coin: CoinModel, range: ChartTimeRange)
}

class CryptoStoreImpl: CryptoStore {
    private enum ChartSampling {
        static let shortRangePointLimit = 240
        static let longRangePointLimit = 180
    }
    
    var coins = CurrentValueSubject<[CoinModel]?, Never>(nil)
    var coinDetails = CurrentValueSubject<CoinDetailModel?, Never>(nil)
    var globalDetails = CurrentValueSubject<MarketDataModel?, Never>(nil)
    var chartPoints = CurrentValueSubject<[ChartPoint], Never>([])
    var chartErrorMessage = CurrentValueSubject<String?, Never>(nil)
    
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
        chartErrorMessage.send(nil)
        
        // 1. Immediate Load from Sparkline (for 7D)
        if range == .week, let sparkline = coin.price, !sparkline.isEmpty {
            chartPoints.send(prepareChartPoints(mapSparklineToPoints(sparkline), for: range))
        }
        
        // 2. Check Cache
        if let cached = historicalCache[coin.id]?[days] {
            chartPoints.send(cached)
            return
        }
        
        // 3. Remote Fetch
        repository.fetchMarketChart(coinID: coin.id, days: days)
            .sink(receiveCompletion: { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.chartErrorMessage.send(Self.chartErrorMessage(for: range, error: error))
            }, receiveValue: { [weak self] points in
                guard let self = self else { return }
                let preparedPoints = self.prepareChartPoints(points, for: range)
                if self.historicalCache[coin.id] == nil { self.historicalCache[coin.id] = [:] }
                self.historicalCache[coin.id]?[days] = preparedPoints
                self.chartErrorMessage.send(nil)
                self.chartPoints.send(preparedPoints)
            })
            .store(in: &cancellables)
    }
    
    private func mapRangeToDays(_ range: ChartTimeRange) -> String {
        switch range {
        case .day: return "1"
        case .week: return "7"
        case .month: return "30"
        case .sixMonths: return "180"
        case .year: return "365"
        case .all: return "max"
        }
    }

    private static func chartErrorMessage(for range: ChartTimeRange, error: Error) -> String {
        if range == .all {
            return "ALL is unavailable on the free API. Try 1Y instead."
        }
        return "Unable to load \(range.rawValue) chart data right now."
    }
    
    private func mapSparklineToPoints(_ prices: [Double]) -> [ChartPoint] {
        let now = Date()
        let count = prices.count
        return prices.enumerated().map { index, price in
            let offset = Double(count - 1 - index) * -3600
            return ChartPoint(date: now.addingTimeInterval(offset), price: price)
        }
    }

    private func prepareChartPoints(_ points: [ChartPoint], for range: ChartTimeRange) -> [ChartPoint] {
        let sortedPoints = points.sorted { $0.date < $1.date }
        guard sortedPoints.count > 2 else { return sortedPoints }

        let maxPoints: Int
        switch range {
        case .day, .week, .month:
            maxPoints = ChartSampling.shortRangePointLimit
        case .sixMonths, .year, .all:
            maxPoints = ChartSampling.longRangePointLimit
        }

        return downsample(sortedPoints, maxPoints: maxPoints)
    }

    private func downsample(_ points: [ChartPoint], maxPoints: Int) -> [ChartPoint] {
        guard points.count > maxPoints, maxPoints >= 3 else { return points }

        let interiorPoints = Array(points.dropFirst().dropLast())
        let interiorBudget = maxPoints - 2
        let bucketSize = Double(interiorPoints.count) / Double(interiorBudget)
        var sampledPoints: [ChartPoint] = [points[0]]

        for bucketIndex in 0..<interiorBudget {
            let startIndex = Int((Double(bucketIndex) * bucketSize).rounded(.down))
            let endIndex = Int((Double(bucketIndex + 1) * bucketSize).rounded(.down))
            let boundedStart = min(startIndex, max(interiorPoints.count - 1, 0))
            let boundedEnd = min(max(endIndex, boundedStart + 1), interiorPoints.count)
            let bucket = Array(interiorPoints[boundedStart..<boundedEnd])

            guard !bucket.isEmpty else { continue }
            let previousPrice = sampledPoints.last?.price ?? bucket[0].price
            let minPoint = bucket.min(by: { $0.price < $1.price }) ?? bucket[0]
            let maxPoint = bucket.max(by: { $0.price < $1.price }) ?? bucket[0]
            let bucketRepresentative =
                abs(maxPoint.price - previousPrice) >= abs(minPoint.price - previousPrice)
                ? maxPoint
                : minPoint
            sampledPoints.append(bucketRepresentative)
        }

        sampledPoints.append(points[points.count - 1])
        return sampledPoints.sorted { $0.date < $1.date }
    }
}
