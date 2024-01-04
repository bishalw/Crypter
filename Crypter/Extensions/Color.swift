//
//  Color.swift
//  Crypter
//
//

import Foundation
import SwiftUI

extension Color {
    
   static let theme = ColorTheme2()
}

struct ColorTheme {
    
    let accent = Color("AccentColor")
    let background = Color("BackgroundColor")
    let green = Color("GreenColor")
    let red = Color("RedColor")
    let secondaryText = Color("SecondaryTextColor")
    
}

struct ColorTheme2 {
    let accent = Color(#colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1))
    let background = Color(#colorLiteral(red: 0.06002914372, green: 0.05083295135, blue: 0.2340437683, alpha: 1))
    let green = Color(#colorLiteral(red: 0.02122644421, green: 0.3172857273, blue: 0.03904580042, alpha: 1))
    let red = Color(#colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1))
    let secondaryText = Color(#colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1))
}

