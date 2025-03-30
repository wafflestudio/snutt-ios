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
        [.showsDivider, .scaleOnPress]
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

    func toggleAction(lecture _: any TimetableInterface.Lecture, type _: ActionButtonType) async throws {
        // noop
    }

    func isSelected(lecture _: any Lecture) -> Bool {
        false
    }

    func fetchMoreLectures() async {
        // noop
    }

    func isToggled(lecture _: any Lecture, type _: ActionButtonType) -> Bool {
        false
    }
}
