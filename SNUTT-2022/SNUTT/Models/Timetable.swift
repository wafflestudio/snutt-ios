//
//  Tiemtable.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

struct Timetable {
    let title: String
    let lectures: [Lecture]
    let theme: Theme
    let userId: String
    let year: Int
    let semester: Int
    let updatedAt: String
    
    var totalCredit: Int {
        lectures.reduce(0) { $0 + $1.credit }
    }
}

extension Timetable {
    init(from dto: TimetableDto) {
        title = dto.title
        lectures = dto.lecture_list.map { .init(from: $0) }
        theme = .init(rawValue: dto.theme) ?? .snutt
        userId = dto.user_id
        year = dto.year
        semester = dto.semester
        updatedAt = dto.updated_at
    }
}

#if DEBUG
extension Timetable {
    static var preview: Timetable {
        return .init(
            title: "나의 시간표",
            lectures: [.preview, .preview, .preview],
            theme: .snutt,
            userId: "1234",
            year: 2022,
            semester: 1,
            updatedAt: "2022-04-02T16:35:53.652Z"
        )
    }
}
#endif
