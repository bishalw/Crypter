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
                .foregroundColor(searchText.isEmpty ? Color.theme.textSecondary : Color.theme.brandPrimary)
            
            TextField("Search by name or symbol...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .foregroundColor(Color.theme.textPrimary)
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
                        .foregroundColor(Color.theme.textSecondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.theme.surfaceSecondary)
                .shadow(color: Color.black.opacity(isFocused ? 0.15 : 0.05), radius: isFocused ? 12 : 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isFocused ? Color.theme.brandPrimary.opacity(0.5) : Color.theme.borderSubtle, lineWidth: 1)
        )
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
