//
//  CoinImageView.swift
//  Crypter
//
//

import SwiftUI

struct CoinImageView<ViewModel>: View where ViewModel: CoinImageViewModel {
    @StateObject var vm: ViewModel

    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if vm.isLoading {
                ProgressView()
            } else {
                Image(systemName: "questionmark")
                    .foregroundColor(Color.theme.secondaryText)
            }
        }
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static var previews: some View {
      Text("To DO")
    }
}

