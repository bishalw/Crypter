//
//  MockNetworkingManager.swift
//  Crypter
//
//  Created by Bishalw on 12/15/22.
//

import Foundation
import Combine

class MockNetworkingManager: NetworkingManager {
    var downloadDataToReturn: Data = Data()
    var downloadDataNetworkTime: Int = 2
    func download(url: URL) -> AnyPublisher<Data, Error> {
        let subject = CurrentValueSubject<Data, Error>(downloadDataToReturn)
        return subject.eraseToAnyPublisher().delay(for: 2, scheduler: RunLoop.main).eraseToAnyPublisher()
    }
    
}
