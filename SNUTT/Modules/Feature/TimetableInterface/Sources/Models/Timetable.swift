//
//  Timetable.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit

public protocol Timetable: Identifiable, Sendable, Codable {
    var id: String { get }
    var title: String { get }
    var quarter: Quarter { get }
    var lectures: [any Lecture] { get }
    var userID: String { get }
}

public protocol TimetableMetadata: Identifiable, Sendable, Codable, Equatable {
    var id: String { get }
    var title: String { get }
    var quarter: Quarter { get }
    var totalCredit: Int { get }
    var isPrimary: Bool { get }
}

public enum Semester: Int, Sendable, Codable, Equatable {
    case first = 1, summer, second, winter
}

@MemberwiseInit(.public)
public struct Quarter: Sendable, Codable, Equatable, Comparable, Identifiable, Hashable {
    public var id: String {
        "\(year)-\(semester.rawValue)"
    }
    public let year: Int
    public let semester: Semester

    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(semester)
    }

    public static func == (lhs: Quarter, rhs: Quarter) -> Bool {
        return lhs.year == rhs.year && lhs.semester == rhs.semester
    }

    public static func < (lhs: Quarter, rhs: Quarter) -> Bool {
        if lhs.year == rhs.year {
            return lhs.semester.rawValue < rhs.semester.rawValue
        } else {
            return lhs.year < rhs.year
        }
    }
}
