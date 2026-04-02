//
//  LocalFileManager.swift
//  Crypter
//
//

import Foundation
import SwiftUI

protocol LocalFileManager {
    func saveImage(image: UIImage, imageName: String, folderName: String)
    func getImage(imageName: String, folderName: String) -> UIImage?
    
}

class LocalFileManagerImpl: LocalFileManager{

    private var fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    func saveImage(image: UIImage, imageName: String, folderName: String){
        
        //create folder
        createFolderIfNeeded(folderName: folderName)
        // get path for image
       guard
            let data = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
            else { return }
        // save image to path
        do {
            try data.write(to: url )
        } catch let error {
            print("Error saving image. ImageName: \(imageName). \(error)")
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        
        guard let url = getURLForImage(imageName: imageName, folderName: folderName),
              fileManager.fileExists(atPath: url.path) else {
              return nil
        }
        
        return UIImage(contentsOfFile: url.path)
    }
    
    private func createFolderIfNeeded(folderName: String){
        
        guard let url = getURLForFolder(folderName: folderName) else { return }
       
        if !fileManager.fileExists(atPath: url.path){
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error creating directory. FolderName: \(folderName). \(error)")
            }
        }
    }
    
    // file://cachedirectory/{folderName}
    private func getURLForFolder(folderName: String) -> URL? {
        
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(folderName)
    }
    // file://cachedirectory/{folderName}/{imageName}.png
    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        guard let folderURL = getURLForFolder(folderName: folderName) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageName + ".png")
    }
}


