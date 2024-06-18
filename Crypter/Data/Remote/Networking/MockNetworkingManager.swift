//
//  MockNetworkingManager.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

class MockNetworkingManager: NetworkingManager {
    var downloadCallCount = 0
    var downloadURLs = [URL]()
    var downloadStub: AnyPublisher<Decodable, Error>?
    
    func download<T>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        downloadCallCount += 1
        downloadURLs.append(url)
        return downloadStub as! AnyPublisher<T, Error>
    }
    
    func downloadImage(url: URL) -> AnyPublisher<UIImage?, Error> {
        return Just(UIImage(named: "placeholder"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
