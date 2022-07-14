//
//  Lecture.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import Foundation

struct Lecture: Identifiable {
    let id: String
    var title: String
    var instructor: String
    var timePlaces: [TimePlace]
    var course_number: String
    var lecture_number: String
    var credit: Int
    var department: String
    var academic_year: String
    var colorIndex: Int
    var classification: String
    var category: String
    var remark: String
    var isCustom: Bool
}

extension Lecture {
    init(from dto: LectureDto) {
        id = dto._id
        title = dto.course_title
        instructor = dto.instructor
        timePlaces = dto.class_time_json.map { .init(from: $0, isCustom: dto.course_number == nil) }
        isCustom = (dto.course_number == nil)
        course_number = dto.course_number ?? ""
        lecture_number = dto.lecture_number ?? ""
        credit = dto.credit
        department = dto.department ?? ""
        academic_year = dto.academic_year ?? ""
        colorIndex = dto.colorIndex
        classification = dto.classification ?? ""
        category = dto.category ?? ""
        remark = dto.remark
    }
}

#if DEBUG
    extension Lecture {
        static var preview: Lecture {
            let instructors = ["염헌영", "엄현상", "김진수", "김형주", "이영기", "배영애", "유성호"]
            let titles = ["시스템프로그래밍", "양궁", "죽음의 과학적 이해", "북한학개론", "Operating System"]
            let departments = ["경영학과", "컴퓨터공학과", "서양사학과", "디자인과"]
            let academic_years = ["1학년", "2학년", "3학년", "학년"]
            return Lecture(id: UUID().uuidString,
                           title: titles.randomElement()!,
                           instructor: instructors.randomElement()!,
                           timePlaces: [.preview, .preview],
                           course_number: "400.313",
                           lecture_number: "001",
                           credit: Int.random(in: 0 ... 4),
                           department: departments.randomElement()!,
                           academic_year: academic_years.randomElement()!,
                           colorIndex: 0,
                           classification: "전선",
                           category: "체육",
                           remark: "",
                           isCustom: false)
        }
    }
#endif
