//
//  LectureReminder.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

/// Represents a lecture reminder configuration
public struct LectureReminder: Equatable, Sendable {
    public let timetableLectureID: String
    public let lectureTitle: String
    public var option: ReminderOption

    public init(timetableLectureID: String, lectureTitle: String, option: ReminderOption) {
        self.timetableLectureID = timetableLectureID
        self.lectureTitle = lectureTitle
        self.option = option
    }
}

extension LectureReminder: Identifiable {
    public var id: String { timetableLectureID }
}
