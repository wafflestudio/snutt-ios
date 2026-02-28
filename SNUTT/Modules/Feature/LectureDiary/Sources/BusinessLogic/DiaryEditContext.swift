//
//  DiaryEditContext.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

public struct DiaryEditContext: Identifiable {
    public let id = UUID()
    let lectureID: String
    let lectureTitle: String

    public init(lectureID: String, lectureTitle: String) {
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
    }
}
