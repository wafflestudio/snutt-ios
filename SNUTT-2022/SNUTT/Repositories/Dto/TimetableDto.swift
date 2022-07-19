//
//  TimetableDto.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Foundation

struct TimetableDto: Codable {
    let _id: String
    let user_id: String
    let year: Int
    let semester: Int
    let title: String
    let lecture_list: [LectureDto]
    let theme: Int
    let updated_at: String
}

struct LectureDto: Codable {
    let _id: String
    let classification: String?
    let department: String?
    let academic_year: String?
    let course_title: String
    let credit: Int
    let class_time: String?
    let class_time_json: [TimePlaceDto]
    let class_time_mask: [Int]
    let instructor: String
    let quota: Int?
    let remark: String?
    let category: String?
    let course_number: String?
    let lecture_number: String?
    let created_at: String
    let updated_at: String
    let color: [String: String]
    let colorIndex: Int
}

struct TimePlaceDto: Codable {
    let _id: String
    let day: Int
    let start: Double
    let len: Double
    let place: String
}

struct TimetableListDto: Codable {
    let _id: String
    let user_id: String
    let year: Int
    let semester: Int
    let title: String
    let lecture_list: [LectureDto]
    let theme: Int
    let updated_at: String
}

struct TimetableMetadataDto: Codable {
    let _id: String
    let year: Int
    let semester: Int
    let title: String
    let updated_at: String
    let total_credit: Int
}

extension TimePlaceDto {
    init(from model: TimePlace) {
        _id = model.id
        day = model.day.rawValue
        start = model.start
        len = model.len
        place = model.place
    }
}

extension LectureDto {
    init(from model: Lecture) {
        // TODO: ""를 nil로 안바꿔도 되는지 확인할 것
        _id = model.id
        classification = model.classification
        department = model.department
        academic_year = model.academicYear
        course_title = model.title
        credit = model.credit
        class_time = model.timeString
        class_time_json = model.timePlaces.map { .init(from: $0 )}
        class_time_mask = model.timeMasks
        instructor = model.instructor
        quota = model.quota
        remark = model.remark
        category = model.category
        course_number = model.courseNumber
        lecture_number = model.lectureNumber
        created_at = model.createdAt
        updated_at = model.updatedAt
        color = model.color
        colorIndex = model.colorIndex
    }
}
