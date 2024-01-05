//
//  StatisticModel.swift
//  Crypter
//
//

import Foundation

struct StatisticModel: Identifiable {
    let id = UUID().uuidString
    let title: String
    let value: String
    let percentageChange: Double?
    
    init(title: String, value: String, percentageChange: Double? = nil){
        self.title = title
        self.value = value
        self.percentageChange = percentageChange
    }
}
extension StatisticModel {
    static func mockStatisticModel() -> StatisticModel {
        let stat = StatisticModel(title: "Market Cap", value: "$12.5Bn", percentageChange: 25.34)
        return stat
    }
}

