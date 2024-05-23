//
//  Timetable.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import Foundation

public protocol Timetable: Identifiable, Sendable, Codable {
    var title: String { get }
    var quarter: Quarter { get }
    var lectures: [any Lecture] { get }
    var userID: String { get }
}

public enum Semester: Int, Sendable, Codable, Equatable {
    case first = 1, summer, second, winter
}

@MemberwiseInit(.public)
public struct Quarter: Sendable, Codable, Equatable {
    public let year: Int
    public let semester: Semester
}
