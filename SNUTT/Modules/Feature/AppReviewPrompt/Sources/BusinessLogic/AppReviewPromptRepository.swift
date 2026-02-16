//
//  AppReviewPromptRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

protocol AppReviewPromptRepository: Sendable {
    func loadState() -> AppReviewPromptState
    func saveState(_ state: AppReviewPromptState)
}
