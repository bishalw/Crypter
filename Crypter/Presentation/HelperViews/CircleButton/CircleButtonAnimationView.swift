//
//  CircleButtonAnimationView.swift
//  Crypter
//

//

import SwiftUI

struct CircleButtonAnimationView: View {
    
    @Binding var animate: Bool
    
    var body: some View {
        Circle()
            .stroke(lineWidth: 5.0)
            .scale(animate ? 1.0 : 0.5)
            .opacity(animate ? 0.0 : 0.5)
        //MARK: fix depricated animation
            .animation(animate ? Animation.easeOut(duration: 1.0) :.none, value: animate)
    }
}

struct CircleButtonAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        CircleButtonAnimationView(animate: .constant(false))
            .preferredColorScheme(.dark)
            .foregroundColor(.red)
            .frame(width: 100, height: 100)
    }
}
