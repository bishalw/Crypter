//
//  CoinDataService.swift
//  Crypter
//
//

import Foundation
import Combine

class CoinDataService: ObservableObject {
    
    // Anything subscribed to published gets notified
    @Published var allCoins: [CoinModel] = []
    var coinSubscription: AnyCancellable?
    
    var networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager){
        self.networkingManager = networkingManager
        getCoins()
    }
    
    
    private func getCoins(){
        let optionalUrl = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h")
        guard let url = optionalUrl else { return }
        
        coinSubscription = networkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoins) in
                self?.allCoins = returnedCoins
                self?.coinSubscription?.cancel()
                
            })
            
    }
    private func handleCompletion (status: Subscribers.Completion<Error>) {
        switch status {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    

}
