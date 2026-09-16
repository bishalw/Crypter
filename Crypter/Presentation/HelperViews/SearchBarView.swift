//
//  SearchBarView.swift
//  Crypter
//

//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isFocused || !searchText.isEmpty ? Color.theme.brandPrimary : Color.theme.textSecondary)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search by name or symbol")
                    .foregroundColor(Color.theme.textSecondary)
            )
            .font(.system(size: 15))
            .foregroundColor(Color.theme.textPrimary)
            .tint(Color.theme.brandPrimary)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .submitLabel(.search)
            .focused($isFocused)

            if !searchText.isEmpty {
                Button {
                    withAnimation(.spring()) {
                        searchText = ""
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Color.theme.brandPrimary : Color.theme.borderSubtle, lineWidth: 1)
        )
        .padding(.vertical, 8)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchBarView(searchText: .constant(""))
                .padding()
                .background(Color.theme.surfaceBackground)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)

            SearchBarView(searchText: .constant("bitcoin"))
                .padding()
                .background(Color.theme.surfaceBackground)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }

    }
}
