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
        _searchViewModel = State(
            initialValue: LectureSearchViewModel(
                timetableViewModel: timetableViewModel
            )
        )
    }

    public var body: some View {
        if #available(iOS 26, *) {
            searchSceneForNewDesign
        } else {
            searchSceneForOldDesign
        }
    }

    private var contentZStack: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(UIColor.quaternaryLabel.withAlphaComponent(0.1)))
                    .frame(height: 1)
                TimetableView(
                    painter: timetableViewModel.makePainter(
                        selectedLecture: searchViewModel.isSearchingDifferentQuarter
                            ? nil
                            : searchViewModel.selectedLecture,
                        selectedTheme: themeViewModel.selectedTheme,
                        availableThemes: themeViewModel.availableThemes
                    )
                )
            }

            TimetableAsset.searchlistBackground.swiftUIColor
                .background(.ultraThinMaterial.opacity(searchViewModel.isSearchingDifferentQuarter ? 1 : 0))
                .ignoresSafeArea(edges: [.bottom, .top])
                .ignoresSafeArea(.keyboard)

            LectureSearchResultScene(viewModel: searchViewModel)
                .ignoresSafeArea(.keyboard)
        }
        .animation(.default, value: searchViewModel.isSearchingDifferentQuarter)
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
                .searchable(text: $searchViewModel.searchQuery, prompt: TimetableStrings.searchInputPlaceholder)
                .onSubmit(of: .search) {
                    errorAlertHandler.withAlert {
                        try await searchViewModel.fetchInitialSearchResult()
                    }
                }
                .navigationTitle(navigationTitle)
                .searchPresentationToolbarBehavior(.avoidHidingContent)
                .toolbar {
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
            TimetableStrings.searchTitle
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
