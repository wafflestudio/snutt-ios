//
//  LectureListViewModel.swift
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

    var theme: Theme {
        if let currentTimetable = appState.timetable.current {
            return appState.theme.themeList.first(where: { $0.id == currentTimetable.themeId || $0.theme == currentTimetable.theme }) ?? Theme(rawValue: 0)
        } else { return Theme(rawValue: 0) }
    }

    var placeholderLecture: Lecture {
        var lecture: Lecture = .init(from: .init(_id: UUID().uuidString, lecture_id: nil, classification: nil, department: nil, academic_year: nil, course_title: "새로운 강의", credit: 0, class_time: nil, class_time_json: [], class_time_mask: [], instructor: "", remark: nil, category: nil, course_number: nil, lecture_number: nil, created_at: nil, updated_at: nil, color: theme.isCustom ? LectureColorDto(fg: theme.colors[0].fg.toHex(), bg: theme.colors[0].bg.toHex()) : nil, colorIndex: theme.isCustom ? 0 : 1, wasFull: false, snuttEvLecture: nil, quota: nil, registrationCount: nil, freshmanQuota: nil))
        if !theme.isCustom { lecture = lecture.withTheme(theme: theme.theme?.rawValue) }
        lecture.timePlaces.append(.init(id: UUID().uuidString,
                                        day: .mon,
                                        startTime: .init(hour: 9, minute: 0),
                                        endTime: .init(hour: 10, minute: 0),
                                        place: "",
                                        isCustom: true,
                                        isTemporary: true))
        return lecture
    }
}
