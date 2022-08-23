//
//  HomeViewModel.swift
//  Crypter
//
//  Created by Bishalw on 8/18/22.
//

import Foundation
import Combine


class HomeViewModel: ObservableObject {
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    private let coinDataService: CoinDataService
    private var cancellables = Set<AnyCancellable>()
    // get data from allCoins in coinData service to HomeviewModel allCoins
    
    init(coinDataService: CoinDataService) {
        self.coinDataService = coinDataService
        addSubscribers()
        }
    
    
    func addSubscribers(){
        // this is array is the published variable in CoinDataService
        coinDataService.$allCoins
            .sink { [weak self] (returnedCoins) in
        // appends it to allCoins array at the top
                self?.allCoins = returnedCoins
                
                
            }
            .store(in: &cancellables)
    }
}
