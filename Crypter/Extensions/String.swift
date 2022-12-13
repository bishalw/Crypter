//
//  String.swift
//  Crypter
//
//  Created by Bishalw on 12/13/22.
//

import Foundation

extension String {
    
    var removingHTMLOccurances: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range:nil)
    }
}
