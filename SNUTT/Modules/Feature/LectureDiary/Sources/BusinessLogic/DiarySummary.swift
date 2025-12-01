//
//  DiarySummary.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import TimetableInterface

public struct DiarySummary: Sendable, Identifiable, Equatable {
    public let id: String
    public let lectureTitle: String
    public let date: Date  // When the diary was written
    public let quarter: Quarter  // Which semester this diary belongs to
    public let shortQuestionReplies: [QuestionReply]
    public let comment: String?

    public init(
        id: String,
        lectureTitle: String,
        date: Date,
        quarter: Quarter,
        shortQuestionReplies: [QuestionReply],
        comment: String?
    ) {
        self.id = id
        self.lectureTitle = lectureTitle
        self.date = date
        self.quarter = quarter
        self.shortQuestionReplies = shortQuestionReplies
        self.comment = comment
    }
}
