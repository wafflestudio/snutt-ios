//
//  LectureSearchRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import Spyable
import TimetableInterface

@Spyable
protocol LectureSearchRepository: Sendable {
    func fetchSearchPredicates(quarter: Quarter) async throws -> [SearchPredicate]
    func fetchSearchResult(
        query: String,
        quarter: Quarter,
        predicates: [SearchPredicate],
        offset: Int,
        limit: Int
    ) async throws -> [any Lecture]
}

