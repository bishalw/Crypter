//
//  ContentView.swift
//  Crypter
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.theme.surfaceBackground
                .ignoresSafeArea()

            VStack(spacing: 40) {

                Text("Accent Color")
                    .foregroundColor(Color.theme.brandPrimary)

                Text("Secondary Text Color")
                    .foregroundColor(Color.theme.textSecondary)

                Text("Red Color")
                    .foregroundColor(Color.theme.statusDanger)

                Text("Green Color")
                    .foregroundColor(Color.theme.statusSuccess)

            }
            .font(.headline)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
