//
//  LectureSearchResultScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import ReviewsInterface
import SharedUIComponents
import SwiftUI
import TimetableInterface
import UIKit

struct LectureSearchResultScene: View {
    @Bindable var viewModel: LectureSearchViewModel
    let isSearchMode: Bool
    @Environment(\.errorAlertHandler) var errorAlertHandler
    @Environment(\.reviewsUIProvider) var reviewsUIProvider
    @Environment(\.isSearching) var isSearching

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.searchDisplayMode {
            case .search:
                VStack(spacing: 0) {
                    if !viewModel.displayPredicates.isEmpty {
                        SearchPredicateScrollView(
                            selectedTagList: viewModel.displayPredicates,
                            deselect: {
                                viewModel.deselectPredicate(predicate: $0)
                            }
                        )
                    }
                    searchContentView
                        .overlay {
                            VStack {
                                switch viewModel.searchState {
                                case .initial:
                                    searchHome
                                case .searched(let lectures) where lectures.isEmpty:
                                    searchEmptyView
                                default: EmptyView()
                                }
                            }
                        }
                }
                .transition(.move(edge: .leading))
            case .bookmark:
                bookmarkContentView
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.defaultSpring, value: viewModel.searchDisplayMode)
        .animation(.defaultSpring, value: viewModel.selectedPredicates)
        .animation(.defaultSpring, value: viewModel.searchState)
        .handleLectureTimeConflict()
        .sheet(isPresented: $viewModel.isSearchFilterOpen) {
            SearchFilterSheet(viewModel: viewModel)
        }
        .sheet(
            isPresented: .init(
                get: { viewModel.targetForLectureDetail != nil },
                set: { _ in viewModel.targetForLectureDetail = nil }
            )
        ) {
            if let entryLecture = viewModel.targetForLectureDetail,
               let searchingQuarter = viewModel.searchingQuarter
            {
                let lectureViewModel = LectureEditDetailViewModel(
                    displayMode: .preview(.showDismissButton, quarter: searchingQuarter),
                    entryLecture: entryLecture
                )
                NavigationStack {
                    LectureEditDetailScene(
                        viewModel: lectureViewModel,
                        belongsToOtherTimetable: false
                    )
                    .handleLectureTimeConflict()
                }
                .tint(.label)
            }
        }
        .sheet(
            isPresented: .init(
                get: { viewModel.targetForLectureReview != nil },
                set: { _ in viewModel.targetForLectureReview = nil }
            )
        ) {
            if let evLectureID = viewModel.targetForLectureReview?.evLecture?.evLectureID {
                reviewsUIProvider.makeReviewsScene(for: evLectureID)
            }
        }
        .onAppear {
            errorAlertHandler.withAlert {
                guard viewModel.availablePredicates.isEmpty, let quarter = viewModel.searchingQuarter else { return }
                try await viewModel.fetchAvailablePredicates(quarter: quarter)
            }
        }
        .onChange(of: viewModel.searchingQuarter) { _, newValue in
            guard let newValue else { return }
            viewModel.resetSearchResult()
            errorAlertHandler.withAlert {
                try await viewModel.fetchAvailablePredicates(quarter: newValue)
            }
        }
        .onChange(of: isSearching) { oldValue, newValue in
            if !newValue {
                viewModel.resetSearchResult()
            }
        }
    }

    private var searchHome: some View {
        SearchTipsView()
            .analyticsScreen(.searchHome, condition: isSearchMode)
    }

    private var searchContentView: some View {
        ExpandableLectureListView(viewModel: viewModel)
            .foregroundStyle(.white)
            .analyticsScreen(.searchList, condition: isSearchMode)
    }

    private var searchEmptyView: some View {
        SearchEmptyView()
            .analyticsScreen(.searchEmpty, condition: isSearchMode)
    }

    private var bookmarkContentView: some View {
        BookmarkListView(viewModel: BookmarkListViewModel(searchViewModel: viewModel))
            .analyticsScreen(.bookmark, condition: isSearchMode)
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
        LectureSearchResultScene(viewModel: viewModel, isSearchMode: true)
    }
}
