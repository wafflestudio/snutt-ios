//
//  LectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import Dependencies
import Foundation
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

    private func createPlaceholderLecture() -> Lecture {
        let mondayMorningTimePlace = TimePlace(
            id: UUID().uuidString,
            day: .mon,
            startTime: .init(hour: 9, minute: 0),
            endTime: .init(hour: 10, minute: 0),
            place: "",
            isCustom: true
        )

        return Lecture(
            id: UUID().uuidString,
            lectureID: nil,
            courseTitle: "새로운 강의",
            timePlaces: [mondayMorningTimePlace],
            lectureNumber: nil,
            instructor: nil,
            credit: nil,
            courseNumber: nil,
            department: nil,
            academicYear: nil,
            remark: nil,
            evLecture: nil,
            colorIndex: 1,
            customColor: nil,
            classification: nil,
            category: nil,
            wasFull: false,
            registrationCount: 0,
            quota: nil,
            freshmenQuota: nil,
            categoryPre2025: nil
        )
    }
}

extension LectureListViewModel {
    var lectures: [Lecture] {
        timetableViewModel.currentTimetable?.lectures ?? []
    }

    func selectLecture(_ lecture: Lecture) {
        timetableViewModel.paths.append(
            .lectureDetail(
                lecture,
                parentTimetable: timetableViewModel.currentTimetable,
                belongsToOtherTimetable: false
            )
        )
        analyticsLogger.logScreen(
            AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .lectureList))
        )
    }

    func createNewLecture() {
        let placeholderLecture = createPlaceholderLecture()
        timetableViewModel.paths.append(.lectureCreate(placeholderLecture))
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
