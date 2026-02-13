//
//  BookmarkListView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct BookmarkListView: View {
    let viewModel: BookmarkListViewModel

    var body: some View {
        if viewModel.lectures.isEmpty {
            EmptyBookmarkList()
        } else {
            ExpandableLectureListView(viewModel: viewModel)
                .foregroundStyle(.white)
                .animation(.defaultSpring, value: viewModel.lectures.count)
        }
    }
}
