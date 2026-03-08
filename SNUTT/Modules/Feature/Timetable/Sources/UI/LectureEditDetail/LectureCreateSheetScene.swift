//
//  LectureCreateSheetScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import SwiftUI
import ThemesInterface
import TimetableInterface

struct LectureCreateSheetScene: View {
    let placeholderLecture: Lecture
    @State private var path: [LectureCreateRoute] = []
    @State private var viewModel: LectureEditDetailViewModel?
    @Environment(\.timetableViewModel) private var timetableViewModel: any TimetableViewModelProtocol
    @Environment(\.themeViewModel) private var themeViewModel

    var body: some View {
        lectureCreateContent
            .task(id: timetableViewModel.currentTimetable?.id) {
                initializeViewModelIfNeeded()
            }
    }

    @ViewBuilder private var lectureCreateContent: some View {
        if let viewModel {
            NavigationStack(path: $path) {
                LectureEditDetailScene(
                    viewModel: viewModel,
                    belongsToOtherTimetable: false,
                    onTapLectureColorSelection: { _ in
                        path.append(.lectureColorSelection)
                    }
                )
                .handleLectureTimeConflict()
                .analyticsScreen(.lectureCreate)
                .navigationDestination(for: LectureCreateRoute.self) { route in
                    switch route {
                    case .lectureColorSelection:
                        let currentTheme = timetableViewModel.currentTimetable?.theme
                        let theme = themeViewModel.availableThemes.first(where: { $0.id == currentTheme?.id })
                        if let theme {
                            LectureColorSelectionListView(
                                theme: theme,
                                viewModel: viewModel
                            )
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
        } else {
            ProgressView()
        }
    }

    private func initializeViewModelIfNeeded() {
        guard viewModel == nil, let currentTimetable = timetableViewModel.currentTimetable else { return }
        viewModel = LectureEditDetailViewModel(
            displayMode: .create(timetable: currentTimetable),
            entryLecture: placeholderLecture
        )
    }
}

private enum LectureCreateRoute: Hashable {
    case lectureColorSelection
}
