//
//  Bookmark.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import Foundation

struct Bookmark {
    var year: Int
    var semester: Int
    var lectures: [Lecture]
}

extension Bookmark {
    init(from dto: BookmarkDto) {
        year = dto.year ?? 0
        semester = dto.semester ?? 0
        let lectureList = dto.lectures ?? []
        lectures = lectureList.map { .init(from: $0)}
    }
}
