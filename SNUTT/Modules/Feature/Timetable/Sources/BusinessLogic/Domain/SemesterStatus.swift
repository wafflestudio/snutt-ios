//
//  SemesterStatus.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import TimetableInterface

/// Represents the current and next semester information based on the current date.
public struct SemesterStatus: Equatable, Sendable {
    /// The semester currently in progress. `nil` if currently in vacation period (between semesters).
    public let current: Quarter?

    /// The next upcoming semester.
    public let next: Quarter

    public init(current: Quarter?, next: Quarter) {
        self.current = current
        self.next = next
    }

    /// Returns the current semester if available, otherwise returns the next semester.
    public var currentOrNext: Quarter {
        current ?? next
    }
}
