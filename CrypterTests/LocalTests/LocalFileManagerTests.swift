//
//  LocalFileManagerTests.swift
//  CrypterTests
//
//

import XCTest
@testable import Crypter

final class LocalFileManagerTests: XCTestCase {
    
    var sut: LocalFileManager!
    
    override func setUp()  {
        super.setUp()
        sut = MockLocalFileManager()
    }
    func test_saveImage() {
        let testImage = UIImage() 
        let imageName = "testImage"
        let folderName = "testFolder"
        
        sut.saveImage(image: testImage, imageName: imageName, folderName: folderName)
        
        // Retrieve the image
        let retrievedImage = sut.getImage(imageName: imageName, folderName: folderName)
        
        // Check if the retrieved image is not nil and matches the saved image
        XCTAssertNotNil(retrievedImage, "The image should be retrieved successfully.")
    }

    func test_getImage() {
        let testImage = UIImage()
        let imageName = "testImage"
        let folderName = "testFolder"
        
        sut.saveImage(image: testImage, imageName: imageName, folderName: folderName)
        
        // Retrieve the image
        let retrievedImage = sut.getImage(imageName: imageName, folderName: folderName)
        
        // Check if the retrieved image is not nil and matches the saved image
        XCTAssertNotNil(retrievedImage, "The image should be retrieved successfully.")
    }
    override func tearDown() {
        
    }


}
