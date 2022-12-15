//
//  XMarkButton.swift
//  Crypter
//
//  Created by Bishalw on 9/18/22.
//

import SwiftUI

struct XMarkButton: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
           dismiss()
    }, label: {
        Image(systemName: "xmark")
            .font(.headline)
        
    })
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton()
    }
}
