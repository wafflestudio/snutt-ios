//
//  ExpandableLectureListViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Combine
import TimetableInterface
import CoreGraphics

@MainActor
protocol ExpandableLectureListViewModel: Sendable, ObservableObject {
    var lectures: [any Lecture] { get }
    var lecturesPublisher: AnyPublisher<[any Lecture], Never> { get }
    var selectedLecture: (any Lecture)? { get }
    func selectLecture(_ : any Lecture)
    func isSelected(lecture: any Lecture) -> Bool
    func isBookmarked(lecture: any Lecture) -> Bool
    func isInCurrentTimetable(lecture: any Lecture) -> Bool
    func isVacancyNotificationEnabled(lecture: any Lecture) -> Bool
    func fetchMoreLectures() async
}

