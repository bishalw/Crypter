//
//  NetworkingManager.swift
//  Crypter
//
//

import Foundation
import Combine 
import UIKit

protocol NetworkingManager {
    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error>
    func downloadImage(url: URL) -> AnyPublisher<UIImage?, Error>
}

class NetworkingManagerImpl: NetworkingManager {
    
    
    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
            return URLSession.shared.dataTaskPublisher(for: url)
                .subscribe(on: DispatchQueue.global(qos: .default))
                .tryMap(handleOutput)
                .decode(type: decodingType, decoder: JSONDecoder())
                .mapError(mapError)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    }
    
    func downloadImage(url: URL) -> AnyPublisher<UIImage?, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap (handleOutput)
            .receive(on: DispatchQueue.main)
            .map { data in return UIImage(data: data) }
            .eraseToAnyPublisher()
    }
    
    //MARK: Private Functions
    
    private func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse
        }
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkingError.httpError(code: httpResponse.statusCode)
        }
        return output.data
    }
    private func mapError(_ error: Error) -> Error {
        if let decodingError = error as? DecodingError {
            return NetworkingError.decodingError(decodingError)
        } else {
            return error
        }
    }
}


