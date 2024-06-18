//
//  NetworkingError.swift
//  Crypter
//
//

import Foundation

enum NetworkingError: Error {
    case invalidResponse
    case httpError(code: Int)
    case invalidData
    case decodingError(Error)
    case invalidURL
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Received an invalid or non-HTTP response from the server."
        case .httpError(let code):
            return "HTTP error \(code)"
        case .invalidData:
            return  "Invalid data received during the request"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidURL:
            return "Not a valid url. Check provided URL for data fetching"
        }
    }
}
