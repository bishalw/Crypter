//
//  CoinImageService.swift
//  Crypter
//
//  Created by Bishalw on 8/23/22.
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil

    
    private var imageSubscription: AnyCancellable?
    private let coin: CoinModel
    
    var networkingManager: NetworkingManager
    
    init(coin: CoinModel, networkingManager: NetworkingManager) {
        self.coin = coin
        self.networkingManager = networkingManager
        getCoinImage()
    }
    private func getCoinImage() {
        let optionalUrl = URL(string: coin.image)
        guard let url = optionalUrl else { return }
        
        imageSubscription = networkingManager.download(url: url)
            .tryMap({ (data)  -> UIImage? in
                    return UIImage(data: data)
                    })
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self] (returnedImage) in
                self?.image = returnedImage
                self?.imageSubscription?.cancel()
                
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
