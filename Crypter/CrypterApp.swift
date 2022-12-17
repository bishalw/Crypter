//
//  CrypterApp.swift
//  Crypter
//
//

import SwiftUI

@main
struct CrypterApp: App {
    
    let prodVm = HomeViewModelImpl(coinDataService: .init(networkingManager: NetworkingManagerImpl()), marketDataService: .init(networkingManager: NetworkingManagerImpl()))
    
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(vm: prodVm)
                    .navigationBarHidden(true)
//                    .environmentObject(ServiceA())
            }
            // all child of homeview has access to vm
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
}


struct ParentView: View {
    @ObservedObject var vm: ViewModel = .init()
    @StateObject var childVm = ChildView.ViewModel()
    var body: some View {
        if vm.boolShouldDiplsay {
            ChildView(vm: childVm)
        } else {
            EmptyView()
        }
    }

    class ViewModel: ObservableObject {
        @Published var boolShouldDiplsay = true
    }
}


struct ChildView: View {
    @ObservedObject var vm: ViewModel
    var body: some View {
        TextField(text: $vm.x) {
            Text("Write something here")
        }
    }
    
    class ViewModel: ObservableObject {
        @Published var x = ""
    }
}
