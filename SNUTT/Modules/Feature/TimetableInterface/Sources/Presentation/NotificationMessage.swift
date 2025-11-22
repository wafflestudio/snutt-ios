//
//  Notification.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

// MARK: - Typed Messages

public struct NavigateToVacancyMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToVacancy")

    public init() {}
}

public struct NavigateToNotificationsMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToNotifications")

    public init() {}
}

public struct NavigateToLectureMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToLecture")

    public let timetableID: String
    public let lectureID: String

    public init(timetableID: String, lectureID: String) {
        self.timetableID = timetableID
        self.lectureID = lectureID
    }
}

public struct NavigateToBookmarkMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToBookmark")

    public init() {}
}

public struct NavigateToTimetableMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToTimetable")

    public let timetableID: String

    public init(timetableID: String) {
        self.timetableID = timetableID
    }
}

public struct NavigateToBookmarkLecturePreviewMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToBookmarkLecturePreview")

    public let year: Int
    public let semester: Semester
    public let lectureID: String

    public init(year: Int, semester: Semester, lectureID: String) {
        self.year = year
        self.semester = semester
        self.lectureID = lectureID
    }
}

public struct NavigateToLectureRemindersMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToLectureReminders")

    public init() {}
}
