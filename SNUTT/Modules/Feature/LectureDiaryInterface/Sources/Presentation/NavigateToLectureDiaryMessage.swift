//
//  NavigateToLectureDiaryMessage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation

public struct NavigateToLectureDiaryMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToLectureDiary")

    public let lectureID: String
    public let lectureTitle: String

    public init(lectureID: String, lectureTitle: String) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
    }
}
