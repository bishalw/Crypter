//
//  CircleButtonView.swift
//  Crypter
//
//

import SwiftUI

struct CircleButtonView: View {
    
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color.theme.textPrimary)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(Color.theme.surfaceSecondary)
            )
            .overlay(
                Circle()
                    .stroke(Color.theme.borderSubtle, lineWidth: 1)
            )
            .padding()
    }
}

struct CircleButtonView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
        CircleButtonView(iconName: "info")
            .padding()
            .previewLayout(.sizeThatFits)
        CircleButtonView(iconName: "plus")
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        }
    }
}
