//
//  LectureSearchScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import SharedUIComponents
import SwiftUI
import TimetableInterface
import TimetableUIComponents

public struct LectureSearchScene: View {
    let timetableViewModel: TimetableViewModel
    @State private var searchViewModel: LectureSearchViewModel
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
        _searchViewModel = State(initialValue: LectureSearchViewModel(
            timetableViewModel: timetableViewModel
        ))
    }

    public var body: some View {
        if #available(iOS 26, *) {
            searchSceneForNewDesign
        } else {
            searchSceneForOldDesign
        }
    }

    // MARK: - Common Components

    private var contentZStack: some View {
        ZStack {
            TimetableZStack(
                painter: timetableViewModel.makePainter(
                    selectedLecture: searchViewModel.selectedLecture,
                    selectedTheme: themeViewModel.selectedTheme,
                    availableThemes: themeViewModel.availableThemes
                )
            )

            TimetableAsset.searchlistBackground.swiftUIColor
                .ignoresSafeArea(edges: .bottom)

            LectureSearchResultScene(
                viewModel: searchViewModel,
                isSearchMode: true
            )
            .ignoresSafeArea(.keyboard)
        }
    }

    private var searchSceneForOldDesign: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchToolBarView(searchViewModel: searchViewModel)
                    .frame(height: 40)

                contentZStack
            }
            .navigationBarTitleDisplayMode(.inline)
            .onLoad {
                searchViewModel.searchingQuarter = timetableViewModel.currentTimetable?.quarter
            }
            .onChange(of: timetableViewModel.currentTimetable?.quarter) { _, newValue in
                searchViewModel.searchingQuarter = newValue
            }
        }
    }

    @available(iOS 26, *)
    private var searchSceneForNewDesign: some View {
        NavigationStack {
            contentZStack
                .navigationBarTitleDisplayMode(.inline)
                .onLoad {
                    searchViewModel.searchingQuarter = timetableViewModel.currentTimetable?.quarter
                }
                .onChange(of: timetableViewModel.currentTimetable?.quarter) { _, newValue in
                    searchViewModel.searchingQuarter = newValue
                }
                .searchable(text: $searchViewModel.searchQuery, prompt: "hello")
                .searchPresentationToolbarBehavior(.avoidHidingContent)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text(navigationTitle).fixedSize()
                    }
                    .sharedBackgroundVisibility(.hidden)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            searchViewModel.isSearchFilterOpen = true
                        } label: {
                            TimetableAsset.searchFilter.swiftUIImage
                        }
                    }
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            searchViewModel.searchDisplayMode.toggle()
                        } label: {
                            switch searchViewModel.searchDisplayMode {
                            case .search:
                                TimetableAsset.navBookmark.swiftUIImage
                            case .bookmark:
                                TimetableAsset.navBookmarkOn.swiftUIImage
                            }
                        }
                    }
                }
        }
    }

    private var navigationTitle: String {
        switch searchViewModel.searchDisplayMode {
        case .search:
            "검색"
        case .bookmark:
            TimetableStrings.searchBookmarkTitle
        }
    }
}

#Preview {
    TabView {
        LectureSearchScene(timetableViewModel: .init())
            .overlaySheet()
    }
}
