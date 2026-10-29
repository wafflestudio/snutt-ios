//
//  EvaluationFeedContent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import MemberwiseInit

@MemberwiseInit
struct EvaluationFeedContent: Equatable, Sendable {
    let evaluations: [LectureEvaluation]
    let cursor: String?
    let canLoadMore: Bool
}
