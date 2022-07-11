//
//  Tiemtable.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

struct Timetable {
    let lectures: [Lecture]
    let theme: Theme
}

extension Timetable {
    init(from dto: TimetableDto) {
        lectures = dto.lecture_list.map { .init(from: $0) }
        theme = .init(rawValue: dto.theme) ?? .SNUTT
    }
}

#if DEBUG
    extension Timetable {
        static var preview: Timetable {
            return .init(lectures: [.preview, .preview, .preview],
                         theme: .SNUTT)
        }
    }
#endif
