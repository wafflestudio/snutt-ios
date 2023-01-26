//
//  BookmarkDto.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import Foundation

struct BookmarkDto: Codable {
    let year: Int
    let semester: Int
    let lectures: [LectureDto]
}

extension BookmarkDto {
    init(from model: Bookmark) {
        year = model.year
        semester = model.semester
        lectures = model.lectures.map { LectureDto(from: $0) }
    }
}
