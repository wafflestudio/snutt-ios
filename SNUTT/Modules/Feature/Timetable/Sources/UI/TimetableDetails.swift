//
//  TimetableDetails.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
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
        case let .lectureDetail(lecture, parentTimetable):
            let belongsToOtherTimetable = (parentTimetable.id != timetableViewModel.currentTimetable?.id)
            let viewModel = LectureEditDetailViewModel(
                displayMode: .normal(timetable: parentTimetable),
                entryLecture: lecture
            )
            LectureEditDetailScene(
                viewModel: viewModel,
                paths: $timetableViewModel.paths,
                belongsToOtherTimetable: belongsToOtherTimetable
            )
            .handleLectureTimeConflict()
        case let .lecturePreview(lecture, quarter):
            let viewModel = LectureEditDetailViewModel(
                displayMode: .preview(.showDismissButton, quarter: quarter),
                entryLecture: lecture
            )
            LectureEditDetailScene(
                viewModel: viewModel,
                paths: $timetableViewModel.paths,
                belongsToOtherTimetable: false
            )
        case let .lectureCreate(placeholderLecture):
            if let currentTimetable = timetableViewModel.currentTimetable {
                let viewModel = LectureEditDetailViewModel(
                    displayMode: .create(timetable: currentTimetable),
                    entryLecture: placeholderLecture
                )
                LectureEditDetailScene(
                    viewModel: viewModel,
                    paths: $timetableViewModel.paths,
                    belongsToOtherTimetable: false
                )
                .handleLectureTimeConflict()
                .analyticsScreen(.lectureCreate)
            } else {
                ProgressView()
            }
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
