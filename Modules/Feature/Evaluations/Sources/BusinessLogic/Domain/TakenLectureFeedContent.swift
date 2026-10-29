//
//  TakenLectureFeedContent.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import TimetableInterface

@MemberwiseInit
struct TakenLectureFeedContent: Equatable, Sendable {
    let takenQuarter: Quarter
    let lectures: [TakenLectureSummary]
}
