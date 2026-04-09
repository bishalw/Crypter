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
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(searchText.isEmpty ? Color.theme.secondaryText : Color.theme.accent)
            
            TextField("Search by name or symbol...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color.theme.accent)
                .disableAutocorrection(true)
                .focused($isFocused)
            
            if !searchText.isEmpty {
                Button {
                    withAnimation(.spring()) {
                        searchText = ""
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.theme.secondaryText)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.background)
                .shadow(color: Color.black.opacity(isFocused ? 0.08 : 0.04), radius: isFocused ? 12 : 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Color.theme.accent.opacity(0.3) : Color.theme.secondaryText.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            SearchBarView(searchText: .constant(""))
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            
            SearchBarView(searchText: .constant(""))
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)
        }
        
    }
}
