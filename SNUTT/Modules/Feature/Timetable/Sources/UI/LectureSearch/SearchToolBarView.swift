//
//  SearchToolBarView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct SearchToolBarView: View {
    @Bindable var searchViewModel: LectureSearchViewModel

    var body: some View {
        HStack(spacing: 0) {
            SearchInputTextField(
                query: $searchViewModel.searchQuery,
                isFilterOpen: $searchViewModel.isSearchFilterOpen
            )
            .onSubmit {
                Task {
                    await searchViewModel.fetchInitialSearchResult()
                }
            }
            .padding(.leading, 5)

            ToolbarButton(image: bookmarkImage, contentInsets: .init(horizontal: 7, vertical: 5)) {
                searchViewModel.searchDisplayMode.toggle()
            }
        }
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
