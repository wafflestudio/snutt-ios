//
//  QuestionItem.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct QuestionItem: Sendable, Identifiable, Equatable {
    public let id: String
    public let question: String
    public let subQuestion: String?
    public let options: [AnswerOption]

    public init(
        id: String,
        question: String,
        subQuestion: String?,
        options: [AnswerOption]
    ) {
        self.id = id
        self.question = question
        self.subQuestion = subQuestion
        self.options = options
    }
}
