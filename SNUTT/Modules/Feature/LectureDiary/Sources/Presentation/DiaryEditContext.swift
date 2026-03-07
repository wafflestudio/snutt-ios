#if FEATURE_LECTURE_DIARY
//
//  DiaryEditContext.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

public struct DiaryEditContext: Sendable {
    public let lectureID: String
    public let lectureTitle: String

    public init(lectureID: String, lectureTitle: String) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
    }
}
#endif
