//
//  MyLectureListViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class LectureListViewModel: BaseViewModel, ObservableObject {
    @Published var isErrorAlertPresented = false
    @Published var errorContent: STError? = nil
    @Published var lectures: [Lecture] = []

    override init(container: DIContainer) {
        super.init(container: container)
        appState.system.$errorContent.assign(to: &$errorContent)
        appState.system.$isErrorAlertPresented.assign(to: &$isErrorAlertPresented)
        appState.timetable.$current.compactMap({ $0?.lectures }).assign(to: &$lectures)
    }

    var errorTitle: String {
        (appState.system.errorContent ?? .UNKNOWN_ERROR).errorTitle
    }

    var errorMessage: String {
        (appState.system.errorContent ?? .UNKNOWN_ERROR).errorMessage
    }
    
    func getPlaceholderLecture() -> Lecture {
        var lecture: Lecture = .init(from: .init(_id: UUID().uuidString, classification: nil, department: nil, academic_year: nil, course_title: "새로운 강의", credit: 0, class_time: nil, class_time_json: [], class_time_mask: [], instructor: "", quota: nil, remark: nil, category: nil, course_number: nil, lecture_number: nil, created_at: nil, updated_at: nil, color: nil, colorIndex: 1))
        lecture.theme = appState.timetable.current?.theme ?? .snutt
        lecture.timePlaces.append(.init(id: UUID().uuidString, day: .mon, start: 1, len: 1, place: "", isCustom: true, isTemporary: true))
        return lecture
    }
}
