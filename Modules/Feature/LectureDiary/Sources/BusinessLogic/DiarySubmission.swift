#if FEATURE_LECTURE_DIARY
//
//  DiarySubmission.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import TimetableInterface

public struct DiarySubmission: Sendable, Equatable {
    public let lectureID: LectureID
    public let dailyClassTypes: [String]
    public let questionAnswers: [QuestionAnswer]
    public let comment: String?

    public init(
        lectureID: LectureID,
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
#endif
