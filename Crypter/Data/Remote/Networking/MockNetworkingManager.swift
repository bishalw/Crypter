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
    var lastestDownloadCall: (URL)? = nil
    
    func download(url: URL) -> AnyPublisher<Data, Error> {
        self.lastestDownloadCall = (url)
        let subject = CurrentValueSubject<Data, Error>(downloadDataToReturn)
        return subject.eraseToAnyPublisher().delay(for: 2, scheduler: RunLoop.main).eraseToAnyPublisher()
    }
}
