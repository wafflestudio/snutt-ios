//
//  AnswerOption.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct AnswerOption: Sendable, Identifiable, Equatable {
    public let id: String
    public let content: String

    public init(id: String, content: String) {
        self.id = id
        self.content = content
    }
}
