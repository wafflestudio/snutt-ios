//
//  EvaluationError.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// Errors surfaced by the native evaluation flow.
enum EvaluationError: LocalizedError, Equatable, Sendable {
    case missingRequiredSort
    case invalidResponse

    var errorDescription: String? {
        EvaluationsStrings.errorLoadFailed
    }

    var recoverySuggestion: String? {
        EvaluationsStrings.errorRetrySuggestion
    }
}
