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
    var shouldShowCancelButton: Bool
    var action: () async -> Void
    var cancel: () -> Void

    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var showCancel: Bool = false

    var body: some View {
        HStack {
            TextField("검색어를 입력하세요", text: $text) { startedEditing in
                isEditing = startedEditing
            }
            .onSubmit {
                showCancel = true
                Task {
                    await action()
                }
            }
            .submitLabel(.search)
            .focused($isFocused)
            .frame(maxHeight: 22)
            .padding(7)
            .padding(.horizontal, 25)
            .onTapGesture {
                isFocused = true
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)

                    Spacer()

                    if !text.isEmpty {
                        Button(action: {
                            isFocused = true
                            text = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }

                    if true {
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
                if showCancel || isEditing {
                    Button(action: {
                        withAnimation(.customSpring) {
                            isFocused = false
                            text = ""
                            showCancel = false
                            cancel()
                        }
                    }) {
                        Text("취소")
                    }
                }
            }
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
        .padding(.top, 5)
        .background(STColor.searchBarBackground)
        .animation(.easeOut(duration: 0.2), value: isEditing)
        .animation(.easeOut(duration: 0.2), value: showCancel)
        .onChange(of: shouldShowCancelButton) { newValue in
            showCancel = newValue
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SearchBar(text: .constant("Constant String"), isFilterOpen: .constant(false), shouldShowCancelButton: false, action: {}, cancel: {})
        }
    }
}
