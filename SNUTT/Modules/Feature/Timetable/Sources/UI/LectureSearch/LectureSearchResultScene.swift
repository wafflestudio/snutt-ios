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
    @Bindable var viewModel: LectureSearchViewModel

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.selectedPredicates.isEmpty {
                SearchPredicateScrollView(
                    selectedTagList: viewModel.selectedPredicates,
                    deselect: { viewModel.deselectPredicate(predicate: $0)
                    }
                )
            }
            if viewModel.lectures.isEmpty {
                SearchTipsView()
            } else {
                VStack {
                    switch viewModel.searchDisplayMode {
                    case .search:
                        searchContentView
                            .transition(.move(edge: .leading))
                    case .bookmark:
                        bookmarkContentView
                            .transition(.move(edge: .trailing))
                    }
                }
                .animation(.defaultSpring, value: viewModel.searchDisplayMode)
            }
        }
        .animation(.defaultSpring, value: viewModel.selectedPredicates)
        .sheet(isPresented: $viewModel.isSearchFilterOpen) {
            SearchFilterSheet(viewModel: viewModel)
        }
        .sheet(isPresented: .init(
            get: { viewModel.targetForLectureDetailSheet != nil },
            set: { _ in viewModel.targetForLectureDetailSheet = nil }
        )) {
            if let entryLecture = viewModel.targetForLectureDetailSheet {
                NavigationStack {
                    LectureEditDetailScene(
                        entryLecture: entryLecture,
                        displayMode: .preview(shouldHideDismissButton: false)
                    )
                }
                .tint(.label)
            }
        }
        .onChange(of: viewModel.searchingQuarter) { _, newValue in
            guard let newValue else { return }
            viewModel.resetSearchResult()
            Task {
                try await viewModel.fetchAvailablePredicates(quarter: newValue)
            }
        }
    }

    private var searchContentView: some View {
        ExpandableLectureListView(viewModel: viewModel)
            .ignoresSafeArea(edges: .bottom)
            .foregroundStyle(.white)
    }

    private var bookmarkContentView: some View {
        EmptyView()
    }
}

#Preview {
    let viewModel = LectureSearchViewModel(timetableViewModel: .init())
    let _ = Task {
        viewModel.searchingQuarter = .init(year: 2024, semester: .winter)
        try await Task.sleep(for: .milliseconds(500))
        try await viewModel.fetchInitialSearchResult()
    }
    ZStack {
        Color.black.opacity(0.5)
        LectureSearchResultScene(viewModel: viewModel)
    }
}
