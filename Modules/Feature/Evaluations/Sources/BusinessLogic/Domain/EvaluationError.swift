//
//  EvaluationError.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation

/// Errors surfaced by the native evaluation flow.
enum EvaluationError: LocalizedError, Equatable, Sendable {
    case missingRequiredSort(String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredSort:
            "강의평을 불러오지 못했습니다."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingRequiredSort(let displayName):
            "\(displayName) 정렬 정보를 불러오지 못했습니다."
        }
    }
}
