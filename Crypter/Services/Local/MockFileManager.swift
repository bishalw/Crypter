//
//  MockFileManager.swift
//  Crypter
//
//  Created by Bishalw on 1/10/24.
//

import Foundation
import UIKit
class MockLocalFileManager: LocalFileManager {
    // Dictionary to mimic file storage
    private var images: [String: UIImage] = [:] 

    func saveImage(image: UIImage, imageName: String, folderName: String) {
        let key = "\(folderName)/\(imageName)"
        images[key] = image
    }

    func getImage(imageName: String, folderName: String) -> UIImage? {
        let key = "\(folderName)/\(imageName)"
        return images[key]
    }
}
