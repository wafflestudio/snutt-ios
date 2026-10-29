//
//  EvaluationSort.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A main feed sort backed by an EV main tag.
struct EvaluationSort: Equatable, Identifiable, Sendable {
    let id: Int64
    let kind: Kind

    init(id: Int64, kind: Kind) {
        self.id = id
        self.kind = kind
    }

    /// A supported ordering option for the main evaluation feed.
    enum Kind: Equatable, Hashable, Sendable {
        case recommended
        case latest
    }
}
