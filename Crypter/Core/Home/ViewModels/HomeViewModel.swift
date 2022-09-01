//
//  HomeViewModel.swift
//  Crypter
//

//

import Foundation
import Combine


class HomeViewModel: ObservableObject {
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    @Published var searchText: String = ""
    
    private let coinDataService: CoinDataService
    private var cancellables = Set<AnyCancellable>()
    // get data from allCoins in coinData service to HomeviewModel allCoins
    
    init(coinDataService: CoinDataService) {
        self.coinDataService = coinDataService
        addSubscribers()
        }
    
    
    func addSubscribers(){
        // this is array is the published variable in CoinDataService
//        coinDataService.$allCoins
//            .sink { [weak self] (returnedCoins) in
//        // appends it to allCoins array at the top
//                self?.allCoins = returnedCoins
//            }
//            .store(in: &cancellables)
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // waits 0.5 seconds for another published value
            .map(filterCoins)
            .sink { [weak self]( returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
    }
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else {
            return coins
        }
        
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) ||
                coin.symbol.lowercased().contains(lowercasedText) ||
                coin.id.lowercased().contains(lowercasedText)
        }
    }
}
