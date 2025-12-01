//
//  QuestionAnswer.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct QuestionAnswer: Sendable, Equatable {
    public let questionID: String
    public let answerIndex: Int

    public init(questionID: String, answerIndex: Int) {
        self.questionID = questionID
        self.answerIndex = answerIndex
    }
}
