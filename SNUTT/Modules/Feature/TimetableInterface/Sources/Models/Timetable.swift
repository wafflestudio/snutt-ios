//
//  Timetable.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import MemberwiseInit
import ThemesInterface

@MemberwiseInit(.public)
public struct Timetable: Identifiable, Sendable, Codable {
    public let id: String
    public let title: String
    public let quarter: Quarter
    public let lectures: [Lecture]
    public let userID: String
    public let theme: ThemeType
    public let isPrimary: Bool
}

@MemberwiseInit(.public)
public struct TimetableMetadata: Identifiable, Sendable, Codable, Equatable {
    public let id: String
    public let title: String
    public let quarter: Quarter
    public let totalCredit: Int
    public let isPrimary: Bool
}

public enum Semester: Int, Sendable, Codable, Equatable {
    case first = 1
    case summer, second, winter
}

public struct Quarter: Sendable, Codable, Equatable, Comparable, Identifiable, Hashable {
    public var id: String {
        "\(year)-\(semester.rawValue)"
    }

    public let year: Int
    public let semester: Semester

    public init(year: Int, semester: Semester) {
        self.year = year
        self.semester = semester
    }

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
