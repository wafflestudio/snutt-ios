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
    @State private var isEditing = false

    var body: some View {
        HStack {
            TextField("검색어를 입력하세요", text: $text)
                .onTapGesture {
                    self.isEditing = true
                    // TODO: make TextField first responder
                }
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
                            }
                        }

                        Button {
                            isFilterOpen.toggle()
                            if isFilterOpen {
                                resignFirstResponder()
                            }
                        } label: {
                            Image("search.filter")
                                .padding(.trailing, 8)
                        }
                    }
                )
                .animation(.easeOut(duration: 0.2), value: isEditing)

            Group {
                if isEditing {
                    Button(action: {
                        text = ""
                        isEditing = false
                        resignFirstResponder()
                    }) {
                        Text("취소")
                    }
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
            .animation(.easeOut(duration: 0.2), value: isEditing)
        }
        .padding(10)
        .background(Color.white)
    }
}

#if canImport(UIKit)
    extension View {
        func resignFirstResponder() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("Constant String"), isFilterOpen: .constant(false))
    }
}
