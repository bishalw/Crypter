//
//  DomainMapper.swift
//  Crypter
//
//  Created by Bishalw on 1/12/24.
//

import Foundation
protocol DomainMapper {
    associatedtype ModelType
    func toDomain() -> ModelType
}
