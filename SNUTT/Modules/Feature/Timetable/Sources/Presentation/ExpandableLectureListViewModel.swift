//
//  ExpandableLectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import CoreGraphics
import Observation
import TimetableInterface

@MainActor
protocol ExpandableLectureListViewModel: Sendable {
    var lectures: [any Lecture] { get }
    var selectedLecture: (any Lecture)? { get }
    func selectLecture(_: any Lecture)
    func isSelected(lecture: any Lecture) -> Bool
    func isBookmarked(lecture: any Lecture) -> Bool
    func isInCurrentTimetable(lecture: any Lecture) -> Bool
    func isVacancyNotificationEnabled(lecture: any Lecture) -> Bool
    func fetchMoreLectures() async
}
