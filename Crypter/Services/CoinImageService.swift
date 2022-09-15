//
//  CoinImageService.swift
//  Crypter
//
//

import Foundation
import SwiftUI
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil

    
    private var imageSubscription: AnyCancellable?
    private let coin: CoinModel
    private var fileManager: LocalFileManager
    private let folderName = "coin_images"
    private let imageName: String
    
    var networkingManager: NetworkingManager
    
    init(coin: CoinModel, networkingManager: NetworkingManager, fileManager: LocalFileManager) {
        self.fileManager = fileManager
        self.coin = coin
        self.imageName = coin.id
        self.networkingManager = networkingManager
        getCoinImage()
    }
   
    private func getCoinImage(){
        if let savedImage = fileManager.getImage(imageName: imageName, folderName: folderName){
                image = savedImage
                print("Retrieved image from File Manager")
        } else {
            downloadCoinImage()
            print("Downloading image now")
        }
        
    }
    private func downloadCoinImage() {
        let optionalUrl = URL(string: coin.image)
        guard let url = optionalUrl else { return }
        
        imageSubscription = networkingManager.download(url: url)
            .tryMap({ (data)  -> UIImage? in
                    return UIImage(data: data)
                    })
            .sink(receiveCompletion: handleCompletion, receiveValue: {[weak self] (returnedImage) in
                guard let self = self, let downloadedImage = returnedImage else { return }
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage, imageName: self.imageName, folderName: self.folderName)
                
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
