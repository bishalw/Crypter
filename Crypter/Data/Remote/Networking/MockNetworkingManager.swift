//
//  MockNetworkingManager.swift
//  Crypter
//
//

import Foundation
import Combine

class MockNetworkingManager: NetworkingManager {
    var downloadDataToReturn: Data = Data()
    var downloadDataNetworkTime: Int = 2
    var lastestDownloadCall: URL? = nil
    
    func download<T>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> where T : Decodable {
        self.lastestDownloadCall = url
        let subject = CurrentValueSubject<Data, Error>(downloadDataToReturn)
        return subject
            .delay(for: .seconds(downloadDataNetworkTime), scheduler: RunLoop.main)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
