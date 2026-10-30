//
//  SearchTag.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A filter tag that narrows lecture search results, such as "3학점".
struct SearchTag: Codable, Hashable, Identifiable, Sendable {
    let id: SearchTagID
    let name: String
}

/// A category of filter tags, such as "학점".
struct SearchTagGroup: Equatable, Identifiable, Sendable {
    let id: Int64
    let name: String
    let tags: [SearchTag]
}
