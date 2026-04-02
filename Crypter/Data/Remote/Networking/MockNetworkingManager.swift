//
//  MockNetworkingManager.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit
class MockNetworkingManager: NetworkingManager {

    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
        // Simulate a successful network response with an empty publisher
        return Empty<T, Error>()
            .eraseToAnyPublisher()
    }

    func downloadImage(url: URL) -> AnyPublisher<UIImage?, Error> {
        // Simulate a successful network response with an empty publisher
        return Empty<UIImage?, Error>()
            .eraseToAnyPublisher()
    }
}
