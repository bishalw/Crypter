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
    
    private var urlSession: URLSession
    private var decoder: JSONDecoder
    
    init(urlSession: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }
    func download<T: Decodable>(url: URL, decodingType: T.Type) -> AnyPublisher<T, Error> {
            return urlSession.dataTaskPublisher(for: url)
                .subscribe(on: DispatchQueue.global(qos: .default))
                .tryMap(handleOutput)
                .decode(type: decodingType, decoder: decoder)
                .mapError(mapError)
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    }
    
    func downloadImage(url: URL) -> AnyPublisher<UIImage?, Error> {
        return urlSession.dataTaskPublisher(for: url)
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



