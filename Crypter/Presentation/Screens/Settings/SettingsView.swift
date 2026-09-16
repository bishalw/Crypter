//
//  SettingsView.swift
//  Crypter
//
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

            NavigationView {
                List {
                    InfoSection
                    CoinGeckoSection
                }
                .font(.system(size: 15, weight: .semibold))
                .tint(Color.theme.brandPrimary)
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.theme.surfaceBackground)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color.theme.textPrimary)
                        })
                        .buttonStyle(.plain)
                    }
                }
            }
        }
}
extension SettingsView {
    private var InfoSection: some View {
        
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text("This app was made to practice effiecient coding using MVVM, Combine and CoreData")
                    .font(.system(size: 15))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.vertical)

            Link("Portfolio", destination: personalURL)
            Link("Github", destination: githubURL)
            Link("LinkedIn", destination: linkedInURL)
        } header: {
            Text("Crypter")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.theme.textSecondary)
        } footer: {
            Text("Bishal W")
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textTertiary)
        }
        .listRowBackground(Color.theme.surfaceSecondary)
    }
    private var CoinGeckoSection: some View {

        Section {
            VStack(alignment: .leading, spacing: 12) {
                Image("Cgecko")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                Text(
                    "This app comes from a free API provided by Coin Gecko and wouldn't have been possible without it")
                    .font(.system(size: 15))
                    .foregroundColor(Color.theme.textSecondary)
            }
            .padding(.vertical)

            Link("Coin Gecko", destination: coingeckoURL)
        } header: {
            Text("CoinGecko")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.theme.textSecondary)
        }
        .listRowBackground(Color.theme.surfaceSecondary)
    }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
