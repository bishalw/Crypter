//
//  CoinDetailDataService.swift
//  Crypter
//
//  Created by Bishalw on 11/16/22.
//

import Foundation
import Combine

protocol CoinDetailDataService: ObservableObject {
    
    var coinDetails: CoinDetailModel? {get set}
    
    
}
class CoinDetailDataServiceImpl: CoinDetailDataService {
    
    // Anything subscribed to published gets notified
    @Published var coinDetails: CoinDetailModel? = nil
    var coinDetailSubscription: AnyCancellable?
    let coin: CoinModel
    
    var networkingManager: NetworkingManager
    
    init(networkingManager: NetworkingManager, coin:CoinModel){
        self.coin = coin
        self.networkingManager = networkingManager
        getCoinDetails()
    }
    
    
     func getCoinDetails(){
         let optionalUrl = URL(string: "https://api.coingecko.com/api/v3/coins/\(coin.id)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false")
        guard let url = optionalUrl else { return }
        
        coinDetailSubscription = networkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self](returnedCoinDetails) in
                self?.coinDetails = returnedCoinDetails
                self?.coinDetailSubscription?.cancel()
                
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
