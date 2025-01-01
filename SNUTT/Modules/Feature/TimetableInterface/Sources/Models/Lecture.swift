//
//  Lecture.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI

public protocol Lecture: Identifiable, Equatable, Sendable, Codable {
    var id: String { get }
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
}

@MemberwiseInit(.public)
public struct EvLecture: Sendable, Equatable, Codable {
    public let evLectureID: Int
    public let avgRating: Double?
    public let evaluationCount: Int?
}

public extension Lecture {
    var isCustom: Bool {
        courseNumber == nil || courseNumber == ""
    }
}
