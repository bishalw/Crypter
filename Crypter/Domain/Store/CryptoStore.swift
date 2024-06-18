//
//  CryptoStore.swift
//  Crypter
//
//

import Foundation
import Combine

class CryptoStore {
    
    var coins: CurrentValueSubject<[CoinModel]?, Never> = CurrentValueSubject(nil)
    var coinDetails: CurrentValueSubject<CoinDetailModel?,Never> = CurrentValueSubject(nil)
    var globalDetails: CurrentValueSubject<MarketDataModel?, Never> = CurrentValueSubject(nil)
    
    private let repository: CryptoRepository
    var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    
    init(repository: CryptoRepository) {
        self.repository = repository
    }
    
    func fetchAllCoins() {
            repository.fetchAllCoins()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching coins: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] coins in
                    self?.coins.send(coins)
                })
                .store(in: &cancellables)
        }

        func fetchCoinDetails(coin: CoinModel) {
            repository.fetchCoinDetail(coin: coin)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching coin details: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] coinDetails in
                    self?.coinDetails.send(coinDetails)
                })
                .store(in: &cancellables)
        }

        func fetchGlobalData() {
            repository.fetchGlobalData()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error fetching global data: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] globalDetails in
                    self?.globalDetails.send(globalDetails)
                })
                .store(in: &cancellables)
        }
}
