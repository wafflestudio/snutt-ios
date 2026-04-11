#if FEATURE_LECTURE_DIARY
//
//  DiaryTargetLecture.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import TimetableInterface

public struct DiaryTargetLecture: Sendable, Identifiable {

    public let id = UUID()
    public let lectureID: LectureID
    public let lectureTitle: String

    public init(lectureID: LectureID, lectureTitle: String) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
    }
}
#endif
