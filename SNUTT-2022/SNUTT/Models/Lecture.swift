//
//  Lecture.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

struct Lecture: Identifiable {
    let id: String
    let title: String
    let instructor: String
    let timePlaces: [TimePlace]
    
    init(from dto: LectureDto) {
        id = dto._id
        title = dto.course_title
        instructor = dto.instructor
        timePlaces = dto.class_time_json.map { .init(from: $0) }
    }
}
