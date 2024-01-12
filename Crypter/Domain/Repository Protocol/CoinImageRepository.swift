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
    var image: CurrentValueSubject<UIImage?,Never> { get }
    func getImage(coin: CoinModel)

}
