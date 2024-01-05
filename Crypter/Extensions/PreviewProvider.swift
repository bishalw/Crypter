//
//  PreviewProvider.swift
//  Crypter
//

//

import Foundation
import SwiftUI

extension PreviewProvider {
    
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

class DeveloperPreview {
    
    static let instance = DeveloperPreview()
    private init() { }
    
    let stat1 = StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34)
    let stat2 = StatisticModel(title: "Total Volume", value: "$1.23Tr")
    let stat3 = StatisticModel(title: "Portfolio Value", value: "$50.4k", percentageChange: -12.34)
    static let stat1 = StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34)
    static let stat2 = StatisticModel(title: "Total Volume", value: "$1.23Tr")
    static let stat3 = StatisticModel(title: "Portfolio Value", value: "$50.4k", percentageChange: -12.34)
    
}

