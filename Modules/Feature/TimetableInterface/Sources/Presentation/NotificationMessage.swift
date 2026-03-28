//
//  Notification.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

// MARK: - Typed Messages

public struct NavigateToVacancyMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToVacancy")

    public init() {}
}

public struct NavigateToSearchMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToSearch")

    public init() {}
}

public struct NavigateToLectureMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToLecture")

    public let timetableID: TimetableID
    public let timetableLectureID: TimetableLectureID

    public init(timetableID: TimetableID, timetableLectureID: TimetableLectureID) {
        self.timetableID = timetableID
        self.timetableLectureID = timetableLectureID
    }
}

public struct NavigateToBookmarkMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToBookmark")

    public init() {}
}

public struct NavigateToTimetableMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToTimetable")

    public let timetableID: TimetableID

    public init(timetableID: TimetableID) {
        self.timetableID = timetableID
    }
}

public struct NavigateToBookmarkLecturePreviewMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToBookmarkLecturePreview")

    public let year: Int
    public let semester: Semester
    public let lectureID: LectureID

    public init(year: Int, semester: Semester, lectureID: LectureID) {
        self.year = year
        self.semester = semester
        self.lectureID = lectureID
    }
}

public struct NavigateToLectureRemindersMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToLectureReminders")

    public init() {}
}
