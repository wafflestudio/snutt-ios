//
//  LectureSearchResultScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import TimetableInterface
import UIKit

struct LectureSearchResultScene: View {
    let viewModel: any ExpandableLectureListViewModel
    var body: some View {
        ZStack {
            if viewModel.lectures.isEmpty {
                SearchTipsView()
            } else {
                ExpandableLectureListView(viewModel: viewModel)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    let viewModel = LectureSearchViewModel()
    _ = Task {
        await viewModel.fetchInitialSearchResult()
    }
    LectureSearchResultScene(viewModel: viewModel)
}
