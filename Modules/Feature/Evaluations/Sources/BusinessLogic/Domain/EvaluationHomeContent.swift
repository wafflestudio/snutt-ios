//
//  EvaluationHomeContent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import MemberwiseInit

@MemberwiseInit
struct EvaluationHomeContent: Equatable, Sendable {
    let selectedSort: EvaluationSort
    let availableSorts: [EvaluationSort]
    let mainFeed: EvaluationFeedContent
    let takenLectureFeed: TakenLectureFeedContent?
}
