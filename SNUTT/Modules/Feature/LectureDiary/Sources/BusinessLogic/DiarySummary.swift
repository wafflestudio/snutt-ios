//
//  DiarySummary.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import TimetableInterface

public struct DiarySubmissionsOfYearSemester: Sendable {
    public let quarter: Quarter
    public let diaryList: [DiarySummary]
}

public struct DiarySummary: Sendable, Identifiable, Equatable {
    public let id: String
    public let lectureID: String
    public let lectureTitle: String
    public let date: Date  // When the diary was written
    public let shortQuestionReplies: [QuestionReply]
    public let comment: String?

    public init(
        id: String,
        lectureID: String,
        date: Date,
        lectureTitle: String,
        shortQuestionReplies: [QuestionReply],
        comment: String?
    ) {
        self.id = id
        self.lectureID = lectureID
        self.lectureTitle = lectureTitle
        self.date = date
        self.shortQuestionReplies = shortQuestionReplies
        self.comment = comment
    }
}
