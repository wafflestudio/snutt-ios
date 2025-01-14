//
//  Bookmark.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import Foundation

struct Bookmark {
    let year: Int
    let semester: Int
    var lectures: [Lecture]
}

extension Bookmark {
    init(from dto: BookmarkDto) {
        year = dto.year
        semester = dto.semester
        lectures = dto.lectures.map { .init(from: $0) }
    }
}
