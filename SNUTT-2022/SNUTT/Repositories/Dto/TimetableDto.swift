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
    let classification: String
    let department: String
    let academic_year: String
    let course_title: String
    let credit: Int
    let class_time: String
    let class_time_json: [ClassTimeJsonDto]
    let class_time_mask: [Int]
    let instructor: String
    let quota: Int
    let remark: String
    let category: String
    let course_number: String
    let lecture_number: String
    let created_at: String
    let updated_at: String
    let color: [String: String]
    let colorIndex: Int
}

struct ClassTimeJsonDto: Codable {
    let _id: String
    let day: Int
    let start: Int
    let len: Int
    let place: String
}
