//
//  CoinImageView.swift
//  Crypter
//
//

import SwiftUI

struct CoinImageView<ViewModel>: View where ViewModel: CoinImageViewModel {
    @StateObject private var vm: ViewModel

    init(vm: ViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        Group {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if vm.isLoading {
                ProgressView()
            } else {
                Image(systemName: "questionmark")
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .task {
            vm.fetchImageIfNeeded()
        }
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static var previews: some View {
      Text("To DO")
    }
}
