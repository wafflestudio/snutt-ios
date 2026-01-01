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
        NavigationStack {
            VStack(spacing: 0) {
                SearchToolBarView(searchViewModel: searchViewModel)
                    .frame(height: 40)

                ZStack {
                    TimetableZStack(
                        painter: timetableViewModel.makePainter(
                            selectedLecture: searchViewModel.selectedLecture,
                            selectedTheme: themeViewModel.selectedTheme,
                            availableThemes: themeViewModel.availableThemes
                        )
                    )

                    Group {
                        TimetableAsset.searchlistBackground.swiftUIColor
                        LectureSearchResultScene(
                            viewModel: searchViewModel,
                            isSearchMode: true
                        )
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitleDisplayMode(.inline)
            .onLoad {
                searchViewModel.searchingQuarter = timetableViewModel.currentTimetable?.quarter
            }
            .onChange(of: timetableViewModel.currentTimetable?.quarter) { _, newValue in
                searchViewModel.searchingQuarter = newValue
            }
        }
    }
}

#Preview {
    TabView {
        LectureSearchScene(timetableViewModel: .init())
            .overlaySheet()
    }
}
