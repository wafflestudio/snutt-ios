//
//  DiarySubmission.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct DiarySubmission: Sendable, Equatable {
    public let lectureID: String
    public let dailyClassTypes: [String]
    public let questionAnswers: [QuestionAnswer]
    public let comment: String?

    public init(
        lectureID: String,
        dailyClassTypes: [String],
        questionAnswers: [QuestionAnswer],
        comment: String?
    ) {
        self.lectureID = lectureID
        self.dailyClassTypes = dailyClassTypes
        self.questionAnswers = questionAnswers
        self.comment = comment
    }
}
