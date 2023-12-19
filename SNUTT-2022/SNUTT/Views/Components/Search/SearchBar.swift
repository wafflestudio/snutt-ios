//
//  SearchBar.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI
import UIKit

struct SearchBar: View {
    @AppStorage("isNewToBookmark") var isNewToBookmark: Bool = true
    @State private var pushToBookmarkScene = false
    @Binding var text: String
    @Binding var isFilterOpen: Bool
    @Binding var displayMode: SearchDisplayMode

    var action: @MainActor () async -> Void

    @State private var isEditing = false
    @FocusState private var isFocused: Bool

    @Environment(\.dependencyContainer) var container: DIContainer?

    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private var searchInputBar: some View {
        TextField("검색어를 입력하세요", text: $text) { startedEditing in
            isEditing = startedEditing
        }
        .onSubmit {
            Task {
                await action()
            }
        }
        .submitLabel(.search)
        .focused($isFocused)
        .frame(maxHeight: 22)
        .padding(7)
        .padding(.leading, 25)
        .padding(.trailing, 70)
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

                Button {
                    isFilterOpen = true
                    feedbackGenerator.impactOccurred()
                } label: {
                    Image("search.filter")
                        .padding(.trailing, 8)
                }
            }
        )
    }

    var body: some View {
        HStack {
            switch displayMode {
            case .search:
                searchInputBar
                    .frame(maxHeight: .infinity)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            case .bookmark:
                HStack {
                    Text("관심강좌")
                        .padding(.horizontal, 5)
                        .frame(maxHeight: .infinity)
                        .font(.system(.headline))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            NavBarButton(imageName: displayMode == .bookmark ? "nav.bookmark.on" : "nav.bookmark") {
                isNewToBookmark = false
                displayMode.toggle()
                if displayMode == .bookmark {
                    isFocused = false
                }
                feedbackGenerator.impactOccurred()
            }
            .circleBadge(condition: isNewToBookmark)
        }
        .padding(.horizontal, 10)
        .background(STColor.searchBarBackground)
        .animation(.easeOut(duration: 0.2), value: isEditing)
        .onChange(of: isFilterOpen) { newValue in
            if newValue {
                isFocused = false
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            SearchBar(text: .constant("Constant String"), isFilterOpen: .constant(false), displayMode: .constant(.bookmark), action: {})
        }
    }
}
