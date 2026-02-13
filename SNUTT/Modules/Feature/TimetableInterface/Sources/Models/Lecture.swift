//
//  Lecture.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import FoundationUtility
import MemberwiseInit
import SwiftUI
import ThemesInterface

@MemberwiseInit(.public)
public struct Lecture: Identifiable, Equatable, Sendable, Codable {
    /// 강의의 고유 ID
    ///
    /// - Note: 동일한 강의라도 시간표에 추가된 경우 고유한 ID가 부여된다.
    public let id: String

    /// 시간표에 추가되지 않은 강의면 `nil`, 추가된 강의면 해당 강의의 고유 ID
    public let lectureID: String?
    public var courseTitle: String
    public var timePlaces: [TimePlace]
    public var lectureNumber: String?
    public var instructor: String?
    public var credit: Int64?
    public var courseNumber: String?
    public var department: String?
    public var academicYear: String?
    public var remark: String?
    public let evLecture: EvLecture?

    /// 0이면 `customColor`에 설정된 색상을 사용하고, 1 이상이면 테마에서 `colorIndex`에 해당하는 색상을 사용한다.
    ///
    /// - SeeAlso: `TimetablePainter.resolveColor(for:)`
    public var colorIndex: Int
    public var customColor: LectureColor?

    /// "분류" (전공, 전선, 전필, 일선, 교양, ...)
    public var classification: String?
    public var category: String?

    public let wasFull: Bool
    public let registrationCount: Int32
    public let quota: Int32?
    public let freshmenQuota: Int32?

    @Init(default: nil) public var categoryPre2025: String?
}

@MemberwiseInit(.public)
public struct EvLecture: Sendable, Equatable, Codable {
    public let evLectureID: Int
    public let avgRating: Double?
    public let evaluationCount: Int?
}

extension Lecture {
    public var isCustom: Bool {
        courseNumber == nil || courseNumber == ""
    }

    /// DB에 저장된 강의 고유 ID (시간표 추가 여부에 관계 없이 모든 유저에게 동일하게 적용되는 ID)
    public var referenceID: String {
        lectureID ?? id
    }
}

// MARK: - LectureDto 변환

extension Components.Schemas.LectureDto {
    public func toLecture() throws -> Lecture {
        let timePlaces = try class_time_json.enumerated().map { index, json in
            try json.toTimePlace(index: index, isCustom: false)
        }
        let evLecture = snuttEvLecture.flatMap {
            EvLecture(
                evLectureID: Int($0.evLectureId),
                avgRating: $0.avgRating,
                evaluationCount: Int($0.evaluationCount)
            )
        }
        return try Lecture(
            id: require(_id),
            lectureID: nil,
            courseTitle: course_title,
            timePlaces: timePlaces,
            lectureNumber: lecture_number,
            instructor: instructor,
            credit: credit,
            courseNumber: course_number,
            department: department,
            academicYear: academic_year,
            remark: remark,
            evLecture: evLecture,
            colorIndex: 0,
            customColor: .temporary,
            classification: classification,
            category: category,
            wasFull: wasFull,
            registrationCount: registrationCount,
            quota: quota,
            freshmenQuota: freshmanQuota
        )
    }
}

extension Components.Schemas.BookmarkLectureDto {
    public func toLecture() throws -> Lecture {
        let timePlaces = try class_time_json.enumerated().map { index, json in
            try json.toTimePlace(index: index, isCustom: false)
        }
        let evLecture = snuttEvLecture.flatMap {
            EvLecture(
                evLectureID: Int($0.evLectureId),
                avgRating: $0.avgRating,
                evaluationCount: Int($0.evaluationCount)
            )
        }
        return try Lecture(
            id: require(_id),
            lectureID: nil,
            courseTitle: course_title,
            timePlaces: timePlaces,
            lectureNumber: lecture_number,
            instructor: instructor,
            credit: credit,
            courseNumber: course_number,
            department: department,
            academicYear: academic_year,
            remark: remark,
            evLecture: evLecture,
            colorIndex: 0,
            customColor: .temporary,
            classification: classification,
            category: category,
            wasFull: false,
            registrationCount: 0,
            quota: quota,
            freshmenQuota: freshmanQuota
        )
    }
}

extension Components.Schemas.ClassPlaceAndTimeLegacyDto {
    public func toTimePlace(index: Int, isCustom: Bool) throws -> TimePlace {
        let weekday = try require(Weekday(rawValue: day.rawValue))
        let start = Int(startMinute).quotientAndRemainder(dividingBy: 60)
        let end = Int(endMinute).quotientAndRemainder(dividingBy: 60)
        return .init(
            id: "\(index)-\(start)-\(end)-\(place ?? "")-\(isCustom)",
            day: weekday,
            startTime: .init(hour: start.quotient, minute: start.remainder),
            endTime: .init(hour: end.quotient, minute: end.remainder),
            place: place ?? "",
            isCustom: isCustom
        )
    }
}
