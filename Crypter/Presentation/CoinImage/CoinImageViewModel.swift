//
//  CoinImageViewModel.swift
//  Crypter
//
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModelImpl: ObservableObject {
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
extension CoinImageViewModelImpl {
    static func createProdInstance(coin: CoinModel) -> CoinImageViewModelImpl {
        let networkingManager = NetworkingManagerImpl()
        let fileManager = LocalFileManagerImpl()
        let coinImageRepository = CoinImageRepositoryImpl(networkingManager: networkingManager, localFileManager: fileManager)
        let coinImageViewModel = CoinImageViewModelImpl(coinImageRepository: coinImageRepository, coin: coin)
        return coinImageViewModel
    }
}
