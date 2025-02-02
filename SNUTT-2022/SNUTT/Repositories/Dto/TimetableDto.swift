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
    let isPrimary: Bool?
    let updated_at: String
    let themeId: String?
}

struct LectureDto: Codable {
    let _id: String
    let lecture_id: String?
    let classification: String?
    let department: String?
    let academic_year: String?
    let course_title: String
    let credit: Int
    let class_time: String?
    let class_time_json: [TimePlaceDto]
    var class_time_mask: [Int]?
    let instructor: String
    let remark: String?
    let category: String?
    let categoryPre2025: String?
    let course_number: String?
    let lecture_number: String?
    let created_at: String?
    let updated_at: String?
    let color: LectureColorDto?
    let colorIndex: Int?
    let wasFull: Bool?
    let snuttEvLecture: EvLectureDto?

    let quota: Int?
    let registrationCount: Int?
    let freshmanQuota: Int?

    var isCustom: Bool {
        course_number == nil || course_number == ""
    }
}

struct EvLectureDto: Codable {
    let evLectureId: Int
    let avgRating: Double?
    let evaluationCount: Int?
}

extension EvLectureDto {
    init(from model: EvLecture) {
        evLectureId = model.evLectureId
        avgRating = model.avgRating
        evaluationCount = model.evaluationCount
    }
}

struct LectureColorDto: Codable {
    let fg: String?
    let bg: String?
}

struct TimePlaceDto: Codable {
    let _id: String?
    let day: Int
    let startMinute: Int
    let endMinute: Int
    let place: String
}

struct BuildingListDto: Decodable {
    let content: [BuildingDto]
    let totalCount: Int
}

struct BuildingDto: Decodable {
    let id: String
    let buildingNumber: String
    let buildingNameKor: String
    let buildingNameEng: String
    let locationInDMS: Location
    let locationInDecimal: Location
    let campus: String
}

struct Location: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

enum Campus: String, Codable {
    case GWANAK, YEONGEON, PYEONGCHANG
}

struct TimetableMetadataDto: Codable {
    let _id: String
    let year: Int
    let semester: Int
    let title: String
    let isPrimary: Bool?
    let updated_at: String
    let total_credit: Int
}

extension TimetableDto {
    init(from model: Timetable) {
        _id = model.id
        user_id = model.userId
        year = model.year
        semester = model.semester
        title = model.title
        lecture_list = model.lectures.map { LectureDto(from: $0) }
        theme = model.theme?.rawValue ?? 0
        isPrimary = model.isPrimary
        updated_at = model.updatedAt
        themeId = model.themeId
    }
}

extension TimePlaceDto {
    init(from model: TimePlace) {
        _id = model.isTemporary ? nil : model.id
        day = model.day.rawValue
        startMinute = model.startMinute
        endMinute = model.endMinute
        place = model.place
    }
}

extension LectureDto {
    init(from model: Lecture) {
        // TODO: ""를 nil로 안바꿔도 되는지 확인할 것
        _id = model.id
        lecture_id = model.lectureId
        classification = model.classification
        department = model.department
        academic_year = model.academicYear
        course_title = model.title
        credit = model.credit
        class_time = nil
        class_time_json = model.timePlaces.map { .init(from: $0) }
        instructor = model.instructor
        quota = model.quota
        freshmanQuota = model.freshmanQuota
        remark = model.remark
        category = model.category
        categoryPre2025 = model.categoryPre2025
        course_number = model.courseNumber
        lecture_number = model.lectureNumber
        created_at = model.createdAt
        updated_at = model.updatedAt
        colorIndex = model.colorIndex
        color = .init(fg: model.color?.fg.toHex(), bg: model.color?.bg.toHex())
        registrationCount = model.registrationCount
        wasFull = model.wasFull
        if let evLecture = model.evLecture {
            snuttEvLecture = .init(from: evLecture)
        } else {
            snuttEvLecture = nil
        }
    }
}
