//
//  SearchInputTextField.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct SearchInputTextField: View {
    @Binding var query: String
    @Binding var isFilterOpen: Bool

    @FocusState private var isFocused

    var body: some View {
        TextField(TimetableStrings.searchInputPlaceholder, text: $query)
            .focused($isFocused)
            .submitLabel(.search)
            .padding(.leading, 35)
            .padding(.trailing, 70)
            .padding(.vertical, 7)
            .onTapGesture {
                isFocused = true
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                HStack(spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)

                    Spacer()

                    if !query.isEmpty {
                        Button(action: {
                            isFocused = true
                            query = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }

                    ToolbarButton(image: TimetableAsset.searchFilter.image) {
                        isFilterOpen = true
                    }
                }
            )
    }
}

#Preview {
    @Previewable @State var query = "컴퓨터"
    @Previewable @State var queryLong = String(repeating: "컴퓨터 ", count: 10)
    SearchInputTextField(query: $query, isFilterOpen: .constant(false))
    SearchInputTextField(query: $queryLong, isFilterOpen: .constant(false))
}
