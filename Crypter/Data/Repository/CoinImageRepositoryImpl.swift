//
//  CoinImageRepostiroy.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

class CoinImageRepositoryImpl: CoinImageRepository{
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

    private func fetchLocalImage(for imageName: String) -> UIImage? {
        return localFileManager.getImage(imageName: imageName, folderName: folderName)
    }

    internal func downloadAndSaveImage(for coin: CoinModel) {
        guard let coinImageURL = CoinAPI.coinImageURL(coin: coin).url else { return }
        imageSubscription = networkingManager.download(url: coinImageURL)
            .tryMap { UIImage(data: $0) }
            .sink(receiveCompletion: handleCompletion, receiveValue: { [weak self] returnedImage in
                guard let self = self, let downloadedImage = returnedImage else { return }
                self.image.send(downloadedImage)
                self.localFileManager.saveImage(image: downloadedImage, imageName: coin.id, folderName: self.folderName)
            })
    }
    internal func handleCompletion(status: Subscribers.Completion<Error>) {
        switch status {
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
                  
}
