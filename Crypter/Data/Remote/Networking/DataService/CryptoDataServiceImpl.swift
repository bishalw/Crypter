//
//  CryptoDataService.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

protocol CryptoDataService {
    var allCoins: CurrentValueSubject<[CoinModel], Never> { get }
    func getMarketData()
    func getCoins()
    func getCoinDetails(coin: CoinModel)
}

class CryptoDataServiceImpl: CryptoDataService {
    
    // Publisher
    var allCoins: CurrentValueSubject<[CoinModel], Never> = CurrentValueSubject<[CoinModel], Never>([])
   
    
    // Subscriptions
    var marketDataSubscription: AnyCancellable?
    var coinSubscription: AnyCancellable?
    var coinDetailSubscription: AnyCancellable?
    var networkingManager: NetworkingManager
    
    // Initialize with a NetworkingManager
    init(networkingManager: NetworkingManager) {
        self.networkingManager = networkingManager
        getMarketData()
        getCoins()
    }
    
//    func getCoins() {
//        let coinsURL = CoinAPI.coins.url
//        guard let url = coinsURL else { return }
//        
//        coinSubscription = networkingManager.download(url: url)
//            .decode(type: [CoinModel].self, decoder: JSONDecoder())
//            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoins) in
//                self?.allCoins.send(returnedCoins)
//                self?.coinSubscription?.cancel()
//            })
//    }
    
    
//    func getCoinDetails(coin: CoinModel) {
//        let coinDetailsURL = CoinAPI.coinDetails(coin: coin).url
//        guard let url = coinDetailsURL else { return }
//        
//        coinDetailSubscription = networkingManager.download(url: url)
//            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
//            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoinDetails) in
//                self?.coinDetails.send(returnedCoinDetails)
//                self?.coinDetailSubscription?.cancel()
//            })
//    }
    
//    private func handleCompletion(status: Subscribers.Completion<Error>) {
//        switch status {
//        case .finished:
//            break
//        case .failure(let error):
//            print(error.localizedDescription)
//        }
//    }
}

