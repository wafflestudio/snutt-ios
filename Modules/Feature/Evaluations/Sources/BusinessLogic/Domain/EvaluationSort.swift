//
//  EvaluationSort.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A main feed sort backed by an EV main tag.
struct EvaluationSort: Hashable, Identifiable, Sendable {
    let id: Int64
    let kind: Kind

    /// A supported ordering option for the main evaluation feed.
    enum Kind: Equatable, Hashable, Sendable {
        case recommended
        case latest
    }
}
