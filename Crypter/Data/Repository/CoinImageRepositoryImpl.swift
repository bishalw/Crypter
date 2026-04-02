//
//  CoinImageRepostiroy.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

class CoinImageRepositoryImpl: CoinImageRepository {

    let networkingManager: NetworkingManager
    let localFileManager: LocalFileManager
    private let folderName = "coin_images"
    
    init(networkingManager: NetworkingManager, localFileManager: LocalFileManager) {
        self.networkingManager = networkingManager
        self.localFileManager = localFileManager
    }
    
    func loadImage(for coin: CoinModel) -> AnyPublisher<UIImage?, Never> {
        if let savedImage = fetchLocalImage(for: coin.id) {
            return Just(savedImage).eraseToAnyPublisher()
        }

        return downloadAndSaveImage(for: coin)
    }
    
    // MARK: private functions

    func fetchLocalImage(for imageName: String) -> UIImage? {
        return localFileManager.getImage(imageName: imageName, folderName: folderName)
    }

    func downloadAndSaveImage(for coin: CoinModel) -> AnyPublisher<UIImage?, Never> {
        guard let coinImageURL = CoinAPI.coinImageURL(coin: coin).url else {
            return Just(nil).eraseToAnyPublisher()
        }

        return networkingManager.downloadImage(url: coinImageURL)
            .handleEvents(receiveOutput: { [weak self] downloadedImage in
                guard let self = self, let image = downloadedImage else { return }
                self.localFileManager.saveImage(image: image, imageName: coin.id, folderName: self.folderName)
            })
            .catch { [weak self] error -> Just<UIImage?> in
                self?.handleCompletion(.failure(error))
                return Just(nil)
            }
            .eraseToAnyPublisher()
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            if let decodingError = error as? DecodingError {
                print("Error decoding image: \(decodingError.localizedDescription)")
            } else {
                print("Error downloading image: \(error.localizedDescription)")
            }
        }
    }
}
