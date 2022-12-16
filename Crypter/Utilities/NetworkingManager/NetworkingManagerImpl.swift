//
//  NetworkingManager.swift
//  Crypter
//
//

import Foundation
import Combine //

protocol NetworkingManager {
    func download(url: URL) -> AnyPublisher<Data, Error>
}

class NetworkingManagerImpl: NetworkingManager {
    
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .badURLResponse(url: let url): return "[🔥] Bad response from URL: \(url)"
            case .unknown: return "[⚠️} Unknown error occured"
            }
        }
    }
    func download(url: URL) -> AnyPublisher<Data, Error>{
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { [weak self] output -> Data in
                guard let strongSelf = self else {
                    throw NetworkingError.unknown
                }
                return try strongSelf.handleURLResponse(output: output, url: url)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    private func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else{
            throw NetworkingError.badURLResponse(url: url)
        }
        return output.data
    }
    
}




