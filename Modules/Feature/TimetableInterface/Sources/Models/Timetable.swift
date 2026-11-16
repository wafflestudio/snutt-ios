//
//  Timetable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Foundation
import MemberwiseInit
import Tagged
import ThemesInterface

@MemberwiseInit(.public)
public struct Timetable: Identifiable, Sendable, Codable {
    public let id: TimetableID
    public let title: String
    public let quarter: Quarter
    public let lectures: [Lecture]
    public let userID: UserID
    public let theme: ThemeType
    public let isPrimary: Bool
}

@MemberwiseInit(.public)
public struct TimetableMetadata: Identifiable, Sendable, Codable, Equatable {
    public let id: TimetableID
    public let title: String
    public let quarter: Quarter
    public let totalCredit: Int
    public var isPrimary: Bool
}

public enum Semester: Int, Sendable, Codable, Equatable {
    case first = 1
    case summer, second, winter
}

extension Semester {
    /// Parses the `semester` query parameter of a deeplink.
    ///
    /// The server sends the semester name (`SPRING`, `SUMMER`, `AUTUMN`, `WINTER`).
    /// Numeric values (`1`...`4`) are still accepted for notifications stored before the server switched to names.
    public init?(deeplinkValue value: String) {
        switch value.uppercased() {
        case "SPRING": self = .first
        case "SUMMER": self = .summer
        case "AUTUMN": self = .second
        case "WINTER": self = .winter
        default:
            guard let semester = Int(value).flatMap(Semester.init(rawValue:)) else { return nil }
            self = semester
        }
    }
}

public struct Quarter: Sendable, Codable, Equatable, Comparable, Identifiable, Hashable {
    public var id: String {
        "\(year)-\(semester.rawValue)"
    }

    public var shortDescription: String {
        "\(String(year).suffix(2))-\(semester.rawValue)"
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
