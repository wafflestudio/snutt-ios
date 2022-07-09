//
//  Tiemtable.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

class Timetable: ObservableObject {
    @Published var lectures: [Lecture]

    init(lectures: [Lecture]) {
        self.lectures = lectures
    }
    
    init(from dto: TimetableDto) {
        lectures = dto.lecture_list.map { .init(from: $0)}
    }
}
