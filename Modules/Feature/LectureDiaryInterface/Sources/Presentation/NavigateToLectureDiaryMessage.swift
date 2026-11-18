#if FEATURE_LECTURE_DIARY
//
//  NavigateToLectureDiaryMessage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesUtility
import Foundation
import TimetableInterface

public struct NavigateToLectureDiaryMessage: NotificationCenter.TypedMessage {
    public static let name = Notification.Name("navigateToLectureDiary")

    public let lectureID: LectureID
    public let lectureTitle: String
    public let referrer: DiaryWriteReferrer

    public init(lectureID: LectureID, lectureTitle: String, referrer: DiaryWriteReferrer) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
        self.referrer = referrer
    }
}
#endif
