//
//  SearchBar.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI
import UIKit

struct SearchBar: View {
    @Binding var text: String
    @Binding var isFilterOpen: Bool
    var action: () -> Void

    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            TextField("검색어를 입력하세요", text: $text) { startedEditing in
                isEditing = startedEditing
                if isEditing {
                    isFilterOpen = false
                }
            }
            .onSubmit(action)
            .focused($isFocused)
            .frame(maxHeight: 22)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)

                    Spacer()

                    if isEditing && !text.isEmpty {
                        Button(action: {
                            self.text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }

                    if !isEditing || text.isEmpty {
                        Button {
                            isFilterOpen.toggle()
                            if isFilterOpen {
                                isFocused = false
                            }
                        } label: {
                            Image("search.filter")
                                .padding(.trailing, 8)
                        }
                    }
                }
            )

            Group {
                if isEditing {
                    Button(action: {
                        isFocused = false
                        text = ""
                    }) {
                        Text("취소")
                    }
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
        .padding(10)
        .background(STColor.searchBarBackground)
        .animation(.easeOut(duration: 0.2), value: isEditing)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Constant String"), isFilterOpen: .constant(false), action: {})
    }
}
