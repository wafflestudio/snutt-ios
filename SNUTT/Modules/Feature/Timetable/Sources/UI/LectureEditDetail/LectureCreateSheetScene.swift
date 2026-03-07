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
    @State private var path: [LectureCreateRoute] = []
    @State private var viewModel: LectureEditDetailViewModel
    @Bindable var timetableViewModel: TimetableViewModel
    @Environment(\.themeViewModel) private var themeViewModel

    init(
        placeholderLecture: Lecture,
        currentTimetable: Timetable,
        timetableViewModel: TimetableViewModel
    ) {
        _viewModel = .init(
            initialValue: LectureEditDetailViewModel(
                displayMode: .create(timetable: currentTimetable),
                entryLecture: placeholderLecture
            )
        )
        self.timetableViewModel = timetableViewModel
    }

    var body: some View {
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
    }
}

private enum LectureCreateRoute: Hashable {
    case lectureColorSelection
}
