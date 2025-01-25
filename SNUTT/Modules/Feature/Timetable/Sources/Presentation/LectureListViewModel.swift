//
//  LectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

@MainActor
struct LectureListViewModel: ExpandableLectureListViewModel {
    private let timetableViewModel: TimetableViewModel

    init(timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
    }

    var renderingOptions: ExpandableLectureListRenderingOptions {
        [.showsDivider]
    }

    let selectedLecture: (any Lecture)? = nil
}

extension LectureListViewModel {
    var lectures: [any Lecture] {
        timetableViewModel.currentTimetable?.lectures ?? []
    }

    func selectLecture(_ lecture: any Lecture) {
        timetableViewModel.paths.append(.lectureDetail(lecture))
    }

    func toggleAction(lecture _: any TimetableInterface.Lecture, type _: ActionButtonType) {
        // noop
    }

    func isSelected(lecture _: any Lecture) -> Bool {
        false
    }

    func isBookmarked(lecture _: any Lecture) -> Bool {
        false
    }

    func isInCurrentTimetable(lecture _: any Lecture) -> Bool {
        false
    }

    func isVacancyNotificationEnabled(lecture _: any Lecture) -> Bool {
        false
    }

    func fetchMoreLectures() async {
        // noop
    }
}
