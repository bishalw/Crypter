//
//  CryptoDataService.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

protocol CryptoDataService {
    var marketData: CurrentValueSubject<MarketDataModel?,Never> { get }
    var allCoins: CurrentValueSubject<[CoinModel], Never> { get }
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> { get }
    var image: CurrentValueSubject<UIImage?,Never> { get }
    func getMarketData()
    func getCoins()
    func getCoinDetails(coin: CoinModel)
}

class CryptoDataServiceImpl: CryptoDataService {
    
    // Publishers
    var marketData: CurrentValueSubject<MarketDataModel?,Never> = CurrentValueSubject<MarketDataModel?,Never>(nil)
    var allCoins: CurrentValueSubject<[CoinModel], Never> = CurrentValueSubject<[CoinModel], Never>([])
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> = CurrentValueSubject<CoinDetailModel?,Never>(nil)
    var image: CurrentValueSubject<UIImage?,Never> = CurrentValueSubject<UIImage?,Never>(nil)
    
    // Subscriptions
    var marketDataSubscription: AnyCancellable?
    var coinSubscription: AnyCancellable?
    var coinDetailSubscription: AnyCancellable?
    var imageSubscription: AnyCancellable?
    
    var networkingManager: NetworkingManager
    
    // Initialize with a NetworkingManager
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
        getMarketData()
        getCoins()
    }
    
    func getMarketData() {
        let marketDataURL = CoinAPI.marketData.url
        guard let url = marketDataURL else { return }
        
        marketDataSubscription = networkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedGlobalData) in
                self?.marketData.send(returnedGlobalData.data)
                self?.marketDataSubscription?.cancel()
            })
    }
    
    func getCoins() {
        let coinsURL = CoinAPI.coins.url
        guard let url = coinsURL else { return }
        
        coinSubscription = networkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoins) in
                self?.allCoins.send(returnedCoins)
                self?.coinSubscription?.cancel()
            })
    }
    
    func downloadCoinImage(coin: CoinModel) {
        let coinImageURL = CoinAPI.coinImageURL(coin: coin).url
        guard let url = coinImageURL else { return }
        
        imageSubscription = networkingManager.download(url: url)
            .tryMap{ (data)  -> UIImage? in
                return UIImage(data: data)
            }
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self] (returnedImage) in
                self?.image.send(returnedImage)
                self?.imageSubscription?.cancel()
            })
    }
    
    func getCoinDetails(coin: CoinModel) {
        let coinDetailsURL = CoinAPI.coinDetails(coin: coin).url
        guard let url = coinDetailsURL else { return }
        
        coinDetailSubscription = networkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoinDetails) in
                self?.coinDetails.send(returnedCoinDetails)
                self?.coinDetailSubscription?.cancel()
            })
    }
    
    private func handleCompletion(status: Subscribers.Completion<Error>) {
        switch status {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}

