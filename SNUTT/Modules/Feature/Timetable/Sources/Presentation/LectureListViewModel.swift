//
//  LectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import SwiftUI
import TimetableInterface

@MainActor
class LectureListViewModel: ExpandableLectureListViewModel {
    private let timetableViewModel: TimetableViewModel

    @Dependency(\.analyticsLogger) private var analyticsLogger

    init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
    }

    var renderingOptions: ExpandableLectureListRenderingOptions {
        [.showsDivider, .scaleOnPress]
    }

    let selectedLecture: Lecture? = nil
    var scrollPosition: Lecture.ID? = nil
}

extension LectureListViewModel {
    var lectures: [Lecture] {
        timetableViewModel.currentTimetable?.lectures ?? []
    }

    func selectLecture(_ lecture: Lecture) {
        guard let currentTimetable = timetableViewModel.currentTimetable else { return }
        timetableViewModel.paths.append(
            .lectureDetail(lecture, parentTimetable: currentTimetable)
        )
        analyticsLogger.logScreen(
            AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .lectureList))
        )
    }

    func createNewLecture() {
        timetableViewModel.presentLectureCreateScene()
    }

    func toggleAction(
        lecture _: TimetableInterface.Lecture,
        type _: ActionButtonType,
        overrideOnConflict _: Bool
    ) async throws {
        // noop
    }

    func isSelected(lecture _: Lecture) -> Bool {
        false
    }

    func fetchMoreLectures() async {
        // noop
    }

    func isToggled(lecture _: Lecture, type _: ActionButtonType) -> Bool {
        false
    }
}
