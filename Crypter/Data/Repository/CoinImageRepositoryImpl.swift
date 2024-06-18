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
    var image: CurrentValueSubject<UIImage?,Never> = CurrentValueSubject(nil)
    var imageSubscription: AnyCancellable?
    private let folderName = "coin_images"
    
    init(networkingManager: NetworkingManager, localFileManager: LocalFileManager) {
        self.networkingManager = networkingManager
        self.localFileManager = localFileManager
    }
    
    func getImage(coin: CoinModel) {
        if let savedImage = fetchLocalImage(for: coin.id) {
            image.send(savedImage)
        } else {
            downloadAndSaveImage(for: coin)
        }
    }

    func fetchLocalImage(for imageName: String) -> UIImage? {
        return localFileManager.getImage(imageName: imageName, folderName: folderName)
    }

    func downloadAndSaveImage(for coin: CoinModel) {
        guard let coinImageURL = CoinAPI.coinImageURL(coin: coin).url else { return }
        let folderName = self.folderName
        let imageName = coin.id
        imageSubscription = networkingManager.downloadImage(url: coinImageURL)
            .sink(receiveCompletion: { completion in
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
            }, receiveValue: { downloadedImage in
                guard let image = downloadedImage else { return }
                self.image.send(image)
                self.localFileManager.saveImage(image: image, imageName: imageName, folderName: folderName)
            })
    }
}
