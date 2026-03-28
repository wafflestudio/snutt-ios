//
//  TimetableDetails.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import NotificationsInterface
import SwiftUI
import ThemesInterface
import VacancyInterface

#if FEATURE_LECTURE_DIARY
import LectureDiaryInterface
#endif

struct TimetableDetails: View {
    let pathType: TimetableDetailSceneTypes
    @Bindable var timetableViewModel: TimetableViewModel
    @Environment(\.notificationsUIProvider) private var notificationsUIProvider
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.vacancyUIProvider) private var vacancyUIProvider

    #if FEATURE_LECTURE_DIARY
    @Environment(\.lectureDiaryUIProvider) private var diaryListUIProvider
    #endif

    var body: some View {
        switch pathType {
        case .lectureList:
            LectureListScene(viewModel: timetableViewModel)
        case .vacancyList:
            AnyView(vacancyUIProvider.makeVacancyScene())
        case let .lectureDetail(lecture, parentTimetable):
            let belongsToOtherTimetable = (parentTimetable.id != timetableViewModel.currentTimetable?.id)
            let viewModel = LectureEditDetailViewModel(
                displayMode: .normal(timetable: parentTimetable),
                entryLecture: lecture
            )
            LectureEditDetailScene(
                viewModel: viewModel,
                belongsToOtherTimetable: belongsToOtherTimetable,
                onTapLectureColorSelection: { timetableViewModel.paths.append(.lectureColorSelection($0)) }
            )
            .handleLectureTimeConflict()
        case let .lecturePreview(lecture, quarter):
            let viewModel = LectureEditDetailViewModel(
                displayMode: .preview(.showDismissButton, quarter: quarter),
                entryLecture: lecture
            )
            LectureEditDetailScene(
                viewModel: viewModel,
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
                    belongsToOtherTimetable: false,
                    onTapLectureColorSelection: { timetableViewModel.paths.append(.lectureColorSelection($0)) }
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

        #if FEATURE_LECTURE_DIARY
        case .lectureDiaryList:
            AnyView(diaryListUIProvider.makeLectureDiaryListView())
        #endif
        }
    }
}
