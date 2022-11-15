//
//  MarketDataService.swift
//  Crypter
//
//

import Foundation
import Combine

class MarketDataService: ObservableObject {
    
    // Anything subscribed to published gets notified
    @Published var marketData: MarketDataModel? = nil
    var marketDataSubscription: AnyCancellable?
    
    var networkingManager: NetworkingManager
    
    
    init(networkingManager: NetworkingManager){
        self.networkingManager = networkingManager
        getMarketData()
    }
    
    
     func getMarketData(){
        let optionalUrl = URL(string: "https://api.coingecko.com/api/v3/global")
        guard let url = optionalUrl else { return }
        
        marketDataSubscription = networkingManager.download(url: url)
            .decode(type: GlobalData.self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedGlobalData) in
                self?.marketData = returnedGlobalData.data
                self?.marketDataSubscription?.cancel()
                
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
