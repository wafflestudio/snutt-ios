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
    let lectures: [BookmarkLectureDto]
}

struct BookmarkLectureDto: Codable {
    let id: String
    let academic_year: String?
    let category: String?
    let class_time: String?
    let real_class_time: String?
    let class_time_json: [TimePlaceDto]
    let class_time_mask: [Int]?
    let classification: String?
    let credit: Int?
    let department: String?
    let instructor: String?
    let lecture_number: String?
    let quota: Int?
    let remark: String?
    let course_number: String?
    let course_title: String?
}

extension BookmarkDto {
    init(from model: Bookmark) {
        year = model.year
        semester = model.semester
        lectures = model.lectures.map { BookmarkLectureDto(from: $0) }
    }
}

extension BookmarkLectureDto {
    init(from model: Lecture) {
        id = model.id
        academic_year = model.academicYear
        category = model.category
        class_time = nil
        real_class_time = nil
        class_time_json = model.timePlaces.map { .init(from: $0) }
        class_time_mask = model.timeMasks
        classification = model.classification
        credit = model.credit
        department = model.department
        instructor = model.instructor
        lecture_number = model.lectureNumber
        quota = model.quota
        remark = model.remark
        course_number = model.courseNumber
        course_title = model.title
    }
}

extension Lecture {
    init(from dto: BookmarkLectureDto) {
        id = dto.id
        title = dto.course_title ?? ""
        instructor = dto.instructor ?? ""
        timePlaces = dto.class_time_json.map { .init(from: $0, isCustom: false) }
        timeMasks = dto.class_time_mask ?? []
        isCustom = false
        courseNumber = dto.course_number ?? ""
        lectureNumber = dto.lecture_number ?? ""
        credit = dto.credit ?? 0
        department = dto.department ?? ""
        academicYear = dto.academic_year ?? ""
        colorIndex = 1
        classification = dto.classification ?? ""
        category = dto.category ?? ""
        remark = dto.remark ?? ""
        quota = dto.quota ?? 0
        createdAt = ""
        updatedAt = ""
    }
}
