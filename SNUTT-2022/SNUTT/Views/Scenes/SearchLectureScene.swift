//
//  SearchLectureScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct SearchLectureScene: View {
    @ObservedObject var viewModel: SearchLectureSceneViewModel

    private enum Design {
        static let searchBarHeight = 44.0
    }

    @State private var reloadSearchList: Int = 0
    @FocusState private var isSearchBarFocused: Bool

    var body: some View {
        ZStack {
            backgroundTimetableView

            VStack(spacing: 0) {
                switch viewModel.displayMode {
                case .search:
                    searchContentView
                        .transition(.move(edge: .leading))
                case .bookmark:
                    bookmarkContentView
                        .transition(.move(edge: .trailing))
                }
            }
        }
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            SearchBar(text: $viewModel.searchText,
                      isFilterOpen: $viewModel.isFilterOpen,
                      displayMode: $viewModel.displayMode,
                      action: viewModel.fetchInitialSearchResult)
                .focused($isSearchBarFocused)
                .frame(height: Design.searchBarHeight)
        }
        .task {
            await viewModel.fetchTags()
        }
        .navigationBarHidden(true)
        .animation(.customSpring, value: viewModel.searchResult?.count)
        .animation(.customSpring, value: viewModel.isLoading)
        .animation(.customSpring, value: viewModel.selectedTagList.count)
        .animation(.customSpring, value: viewModel.displayMode)
        .onChange(of: viewModel.isLoading) { _ in
            withAnimation(.customSpring) {
                reloadSearchList += 1
            }
        }
        .onChange(of: isSearchBarFocused) { isSearching in
            if isSearching {
                viewModel.selectedLecture = nil
            }
        }

        let _ = debugChanges()
    }

    private var backgroundTimetableView: some View {
        Group {
            VStack {
                TimetableZStack(current: viewModel.currentTimetableWithSelection,
                                config: viewModel.timetableConfigWithAutoFit)
                    .animation(.customSpring, value: viewModel.selectedLecture?.id)
            }
            STColor.searchListBackground
        }
        .ignoresSafeArea(.keyboard)
    }

    private var searchContentView: some View {
        VStack(spacing: 0) {
            if viewModel.selectedTagList.count > 0 {
                SearchTagsScrollView(selectedTagList: viewModel.selectedTagList, deselect: viewModel.deselectTag)
            }

            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity, alignment: .center)
                } else if viewModel.searchResult == nil {
                    SearchTips()
                } else if viewModel.searchResult?.count == 0 {
                    EmptySearchResult()
                } else if let searchResult = viewModel.searchResult {
                    ExpandableLectureList(
                        viewModel: .init(container: viewModel.container),
                        lectures: searchResult,
                        selectedLecture: $viewModel.selectedLecture,
                        fetchMoreLectures: viewModel.fetchMoreSearchResult
                    )
                    .animation(.customSpring, value: viewModel.selectedLecture?.id)
                    .id(reloadSearchList) // reload everything when any of the search conditions changes
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bookmarkContentView: some View {
        BookmarkScene(viewModel: .init(container: viewModel.container))
    }
}

enum SearchDisplayMode {
    case search
    case bookmark

    mutating func toggle() {
        switch self {
        case .search:
            self = .bookmark
        case .bookmark:
            self = .search
        }
    }
}

private struct SelectedLectureKey: EnvironmentKey {
    static let defaultValue: Lecture? = nil
}

extension EnvironmentValues {
    var selectedLecture: Lecture? {
        get { self[SelectedLectureKey.self] }
        set { self[SelectedLectureKey.self] = newValue }
    }
}

#if DEBUG
    struct SearchLectureScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                SearchLectureScene(viewModel: .init(container: .preview))
            }
        }
    }
#endif
