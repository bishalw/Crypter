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
    var downloadStubs: [String: AnyPublisher<Any, Error>] = [:]
    
    func setDownloadStub<T: Decodable>(for type: T.Type, publisher: AnyPublisher<T, Error>) {
        let key = String(describing: type)
        downloadStubs[key] = publisher.map { $0 as Any }.eraseToAnyPublisher()
    }
    
    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
        downloadCallCount += 1
        downloadURLs.append(url)
        
        let key = String(describing: decodingType)
        guard let stub = downloadStubs[key] as? AnyPublisher<T, Error> else {
            return Fail(error: NetworkingError.unknownError).eraseToAnyPublisher()
        }
        
        return stub
    }
    
    func downloadImage(url: URL) -> AnyPublisher<UIImage?, Error> {
        downloadCallCount += 1
        downloadURLs.append(url)
        
        return Just(UIImage(named: "placeholder"))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}