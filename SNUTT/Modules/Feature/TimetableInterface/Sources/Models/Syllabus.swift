//
//  Syllabus.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation

public struct Syllabus: Sendable, Codable, Equatable {
    public let url: String

    public init(url: String) {
        self.url = url
    }
}
