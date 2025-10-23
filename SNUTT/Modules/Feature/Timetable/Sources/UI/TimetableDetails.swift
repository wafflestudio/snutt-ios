//
//  TimetableDetails.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface

struct TimetableDetails: View {
    let pathType: TimetableDetailSceneTypes
    @Bindable var timetableViewModel: TimetableViewModel
    @Environment(\.notificationsUIProvider) private var notificationsUIProvider
    @Environment(\.themeViewModel) private var themeViewModel

    var body: some View {
        switch pathType {
        case .lectureList:
            LectureListScene(viewModel: timetableViewModel)
        case let .lectureDetail(lecture):
            LectureEditDetailScene(
                timetableViewModel: timetableViewModel,
                entryLecture: lecture,
                displayMode: .normal,
                paths: $timetableViewModel.paths
            )
            .handleLectureTimeConflict()
        case let .lectureCreate(placeholderLecture):
            LectureEditDetailScene(
                timetableViewModel: timetableViewModel,
                entryLecture: placeholderLecture,
                displayMode: .create,
                paths: $timetableViewModel.paths
            )
            .handleLectureTimeConflict()
            .analyticsScreen(.lectureCreate)
        case let .lectureColorSelection(viewModel):
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
        case .notificationList:
            AnyView(notificationsUIProvider.makeNotificationsScene())
        }
    }
}
