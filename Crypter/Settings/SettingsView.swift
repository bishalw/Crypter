//
//  SettingsView.swift
//  Crypter
//
//  Created by Bishalw on 12/14/22.
//

import SwiftUI

struct SettingsView: View {


    let defaultURL = URL(string: "https://www.google.com")!
    let linkedInURL = URL(string: "https://www.linkedin.com/in/bishalw/")!
    let coingeckoURL = URL (string: "https://www.coingecko.com")!
    let personalURL = URL(string: "https://www.bishalwagle.com")!
    let githubURL = URL (string: "https://github.com/bishalw")!
    @Environment(\.presentationMode) var presentationMode
    var body: some View {

        ZStack {
            NavigationView {
                List {
                    InfoSection
                    CoinGeckoSection
                }
                .font(.headline)
                .accentColor(.blue)
                .listStyle(GroupedListStyle())
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                                              presentationMode.wrappedValue.dismiss()
                                          }, label: {
                                              Image(systemName: "xmark")
                                                  .font(.headline)
                                          })
                    }
                }
            }
        }
    }
}
extension SettingsView {
    private var InfoSection: some View {
        Section(header: Text("Crypter"), footer: Text("Bishal W")) {
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("This app was made to practice effiecient coding using MVVM, Combine and CoreData")
                    .font(.callout)
                    .fontWeight(.medium)
                    
            }
            .padding(.vertical)
            
            Link("Portfolio", destination: personalURL)
            Link("Github", destination: githubURL)
            Link("LinkedIn", destination: linkedInURL)
        }
    }
    private var CoinGeckoSection: some View {
        
            Section(header: Text("CoinGeck0")) {
                VStack(alignment: .leading) {
                    Image("Cgecko")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    Text("This app comes from a free API provided by Coin Geck and wouldn't have been possible without it")
                        .font(.callout)
                        .fontWeight(.medium)
                        
                }
                .padding(.vertical)
                
                Link("Coin Gecko", destination: coingeckoURL)
                
            }
        
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
