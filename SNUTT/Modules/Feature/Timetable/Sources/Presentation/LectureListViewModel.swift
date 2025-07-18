//
//  LectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

@MainActor
class LectureListViewModel: ExpandableLectureListViewModel {
    private let timetableViewModel: TimetableViewModel

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
        timetableViewModel.paths.append(.lectureDetail(lecture))
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
