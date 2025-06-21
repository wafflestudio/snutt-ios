//
//  Lecture.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

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
}
