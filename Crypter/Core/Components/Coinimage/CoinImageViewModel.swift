//
//  CoinImageViewModel.swift
//  Crypter
//
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    
    private let coin: CoinModel
    private let coinImageservice: CoinImageService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel, coinImageService: CoinImageService){
        self.coin = coin
        self.coinImageservice = coinImageService
        self.addSubscribers()
        self.isLoading = true
    }
    
    private func addSubscribers(){
        
        coinImageservice.$image
            .sink { [weak self](_) in
                self?.isLoading = false
            } receiveValue: { [weak self] (returnedImage) in
                self?.image = returnedImage
            }
            .store(in: &cancellables)

    }
}

//func main(){
//    let x = DeveloperPreview.instance.coin
//    let networkingManager = RealNetworkingManager()
//    let coinImageService = CoinImageService(coin: x, networkingManager: networkingManager)
//    let y = CoinImageViewModel(coin: x, coinImageService: coinImageService)
//}
