//
//  SearchBar.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isFilterOpen: Bool
    @State private var isEditing = false

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                TextField("검색어를 입력하세요", text: $text) { startedEditing in
                    if startedEditing {
                        isEditing = true
                    } else {
                        isEditing = false
                    }
                }.padding(.vertical, 7)

                if isEditing && !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }.padding(.trailing, 8)
                } else {
                    Button {
                        isFilterOpen.toggle()
                    } label: {
                        Image("search.filter")
                    }.padding(.trailing, 8)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Group {
                if isEditing {
                    Button(action: {
                        text = ""
                        isEditing = false
                    }) {
                        Text("취소")
                    }
                    .padding(.trailing, 2)
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
            .animation(.easeOut(duration: 0.2), value: isEditing)
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Constant String"), isFilterOpen: .constant(false))
    }
}
