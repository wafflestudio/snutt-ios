//
//  Lecture.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import Foundation

struct Lecture: Identifiable {
    let id: String
    let title: String
    let instructor: String
    let timePlaces: [TimePlace]
}

extension Lecture {
    init(from dto: LectureDto) {
        id = dto._id
        title = dto.course_title
        instructor = dto.instructor
        timePlaces = dto.class_time_json.map { .init(from: $0) }
    }
}


#if DEBUG
extension Lecture {
    static var preview: Lecture {
        let instructors = ["염헌영", "엄현상", "김진수", "김형주", "이영기", "배영애", "유성호"]
        let titles = ["시스템프로그래밍", "양궁", "죽음의 과학적 이해", "북한학개론", "Operating System"]
        return Lecture(id: UUID().uuidString, title: titles.randomElement()!, instructor: instructors.randomElement()!, timePlaces: [.preview, .preview])
    }
}
#endif
