//
//  MyLectureListViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class LectureListViewModel: BaseViewModel, ObservableObject {
    @Published var lectures: [Lecture] = []

    override init(container: DIContainer) {
        super.init(container: container)
        appState.timetable.$current.compactMap { $0?.lectures }.assign(to: &$lectures)
    }

    var placeholderLecture: Lecture {
        var lecture: Lecture = .init(from: .init(_id: UUID().uuidString, classification: nil, department: nil, academic_year: nil, course_title: "새로운 강의", credit: 0, class_time: nil, class_time_json: [], class_time_mask: [], instructor: "", quota: nil, remark: nil, category: nil, course_number: nil, lecture_number: nil, created_at: nil, updated_at: nil, color: nil, colorIndex: 1))
        lecture.theme = appState.timetable.current?.theme ?? .snutt
        lecture.timePlaces.append(.init(id: UUID().uuidString, day: .mon, startTime: "9:00", endTime: "10:00", place: "", isCustom: true, isTemporary: true))
        return lecture
    }
}
