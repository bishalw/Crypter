//
//  CoinImageRepository.swift
//  Crypter
//
//

import Foundation
import Combine
import UIKit

/*Protocol for dependency injection.
Domain folder if needed to seperate into a seperate module
 */
protocol CoinImageRepository {
    func loadImage(for coin: CoinModel) -> AnyPublisher<UIImage?, Never>
}
