//
//  SearchToolBarView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct SearchToolBarView: View {
    @Bindable var searchViewModel: LectureSearchViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        HStack(spacing: 0) {
            switch searchViewModel.searchDisplayMode {
            case .search:
                SearchInputTextField(
                    query: $searchViewModel.searchQuery,
                    isFilterOpen: $searchViewModel.isSearchFilterOpen
                )
                .onSubmit {
                    errorAlertHandler.withAlert {
                        try await searchViewModel.fetchInitialSearchResult()
                    }
                }
                .padding(.leading, 10)
                .transition(.move(edge: .leading).combined(with: .opacity))
            case .bookmark:
                HStack {
                    Text("관심강좌")
                        .padding(.horizontal, 15)
                        .font(.system(.headline))
                    Spacer()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            ToolbarButton(image: bookmarkImage, contentInsets: .init(horizontal: 7, vertical: 5)) {
                searchViewModel.searchDisplayMode.toggle()
            }
        }
        .animation(.defaultSpring, value: searchViewModel.searchDisplayMode)
    }

    private var bookmarkImage: UIImage {
        switch searchViewModel.searchDisplayMode {
        case .search:
            TimetableAsset.navBookmark.image
        case .bookmark:
            TimetableAsset.navBookmarkOn.image
        }
    }
}

#Preview {
    SearchToolBarView(searchViewModel: .init(timetableViewModel: .init()))
}
