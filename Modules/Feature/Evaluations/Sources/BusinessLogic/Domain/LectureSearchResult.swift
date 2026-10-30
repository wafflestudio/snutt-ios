//
//  LectureSearchResult.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// A lecture matched by an evaluation search.
struct LectureSearchResult: Equatable, Identifiable, Sendable {
    let info: EvaluationLectureInfo
    let averageRating: Double?
    let evaluationCount: Int

    var id: EvaluationLectureID { info.id }
}

/// A page of lecture search results.
struct LectureSearchPage: Equatable, Sendable {
    let results: [LectureSearchResult]
    let page: Int
    let isLast: Bool
}

/// A lecture search request: free text plus filter tags.
struct LectureSearchQuery: Equatable, Sendable {
    var text: String
    var tags: [SearchTag]

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// A query is searchable once it has text or at least one filter.
    var isSearchable: Bool {
        !trimmedText.isEmpty || !tags.isEmpty
    }
}
