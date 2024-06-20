//
//  CoinImageViewModel.swift
//  Crypter
//
//

import Foundation
import SwiftUI
import Combine

protocol CoinImageViewModel: ObservableObject{
    var image: UIImage? { get set }
    var isLoading: Bool { get set }
}

class CoinImageViewModelImpl: ObservableObject, CoinImageViewModel {
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false

    private let coinImageRepository: CoinImageRepository
    private let coin: CoinModel
    private var cancellables = Set<AnyCancellable>()

    init(coinImageRepository: CoinImageRepository, coin: CoinModel) {
        self.coinImageRepository = coinImageRepository
        self.coin = coin
        addSubscribers()
        fetchImage()
    }

    private func addSubscribers() {
        coinImageRepository.image
            .receive(on: RunLoop.main)
            .sink { [weak self] returnedImage in
                self?.isLoading = false
                self?.image = returnedImage
            }
            .store(in: &cancellables)
    }

    private func fetchImage() {
        isLoading = true
        coinImageRepository.getImage(coin: coin)
    }
}
