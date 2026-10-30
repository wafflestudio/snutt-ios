//
//  LoadState.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// Content that is either still loading or ready to render.
///
/// Load failures are surfaced through `ErrorAlertHandler`, so there is no failed case:
/// a screen keeps its skeleton until a later attempt succeeds.
enum LoadState<Value: Sendable>: Sendable {
    case loading
    case loaded(Value)

    var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }
}

extension LoadState: Equatable where Value: Equatable {}
