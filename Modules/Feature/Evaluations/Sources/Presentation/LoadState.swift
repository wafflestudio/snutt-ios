//
//  LoadState.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// Content that is loading, ready to render, or failed to load before any content arrived.
///
/// Once content is shown, a failed reload keeps it and only reports the error, so `.failed`
/// means the screen has nothing to show but a retry.
enum LoadState<Value: Sendable>: Sendable {
    case loading
    case loaded(Value)
    case failed

    var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }

    var isFailed: Bool {
        if case .failed = self { true } else { false }
    }

    /// The state to show after a load attempt failed. A cancelled attempt keeps loading, since the
    /// screen retries when it appears again.
    func afterFailedLoad() -> LoadState {
        guard value == nil, !Task.isCancelled else { return self }
        return .failed
    }
}

extension LoadState: Equatable where Value: Equatable {}
