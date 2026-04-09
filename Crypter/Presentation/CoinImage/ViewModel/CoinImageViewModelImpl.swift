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
    func fetchImageIfNeeded()
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
    }

    func fetchImageIfNeeded() {
        guard image == nil, !isLoading else { return }
        fetchImage()
    }

    private func fetchImage() {
        isLoading = true
        coinImageRepository.loadImage(for: coin)
            .receive(on: RunLoop.main)
            .sink { [weak self] returnedImage in
                self?.isLoading = false
                self?.image = returnedImage
            }
            .store(in: &cancellables)
    }
}
