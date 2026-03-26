//
//  LectureReminder.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import Tagged
import TimetableInterface

/// Represents a lecture reminder configuration
public struct LectureReminder: Equatable, Sendable {
    public let timetableLectureID: TimetableLectureID
    public let lectureTitle: String
    public var option: ReminderOption

    public init(timetableLectureID: TimetableLectureID, lectureTitle: String, option: ReminderOption) {
        self.timetableLectureID = timetableLectureID
        self.lectureTitle = lectureTitle
        self.option = option
    }
}

extension LectureReminder: Identifiable {
    public var id: TimetableLectureID { timetableLectureID }
}
