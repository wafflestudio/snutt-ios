//
//  Lecture.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI

public protocol Lecture: Identifiable, Equatable, Sendable, Codable {
    /// 강의의 고유 ID
    ///
    /// - Note: 동일한 강의라도 시간표에 추가된 경우 고유한 ID가 부여된다.
    var id: String { get }

    /// 시간표에 추가되지 않은 강의면 `nil`, 추가된 강의면 해당 강의의 고유 ID
    var lectureID: String? { get }
    var courseTitle: String { get }
    var timePlaces: [TimePlace] { get }
    var lectureNumber: String? { get }
    var instructor: String? { get }
    var credit: Int64? { get }
    var courseNumber: String? { get }
    var department: String? { get }
    var academicYear: String? { get }
    var remark: String? { get }
    var evLecture: EvLecture? { get }
    var customColor: LectureColor? { get }

    /// "분류" (전공, 전선, 전필, 일선, 교양, ...)
    var classification: String? { get }
    var category: String? { get }

    var quota: Int32? { get }
    var freshmenQuota: Int32? { get }
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
