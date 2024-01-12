//
//  NetworkingManager.swift
//  Crypter
//
//

import Foundation
import Combine 

protocol NetworkingManager {
    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error>
}

class NetworkingManagerImpl: NetworkingManager {

    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
            return URLSession.shared.dataTaskPublisher(for: url)
                .subscribe(on: DispatchQueue.global(qos: .default))
                .tryMap { output in
                    guard let httpResponse = output.response as? HTTPURLResponse else {
                        throw NetworkingError.invalidResponse
                    }
                    guard 200...299 ~= httpResponse.statusCode else {
                        throw NetworkingError.httpError(code: httpResponse.statusCode)
                    }
                    return output.data
                }
                .decode(type: decodingType, decoder: JSONDecoder())
                .mapError { error in
                    if let decodingError = error as? DecodingError {
                        return NetworkingError.decodingError(decodingError)
                    } else {
                        return error
                    }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
}



