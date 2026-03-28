//
//  CourseBook.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

public struct CourseBook: Sendable, Codable, Equatable {
    public let quarter: Quarter
    public let updatedAt: Date

    public init(quarter: Quarter, updatedAt: Date) {
        self.quarter = quarter
        self.updatedAt = updatedAt
    }
}
