//
//  LectureSearchResultDataSource.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import Observation
import TimetableInterface

@Observable
@MainActor
class LectureSearchResultDataSource {
    enum SearchState: Equatable {
        case initial
        case searched([Lecture])
    }

    @ObservationIgnored
    @Dependency(\.lectureSearchRepository) private var searchRepository

    private var quarter: Quarter?
    private var searchQuery = ""
    private let pageLimit = 20
    private var currentPage = 0
    private var isLoading = false
    private var canFetchMore = true
    private var predicates: [SearchPredicate]?
    private(set) var searchState: SearchState = .initial

    private func fetchSearchResult(
        query: String,
        at page: Int,
        quarter: Quarter,
        predicates: [SearchPredicate]
    ) async throws -> [Lecture] {
        let offset = pageLimit * page
        let response = try await searchRepository.fetchSearchResult(
            query: query,
            quarter: quarter,
            predicates: predicates,
            offset: offset,
            limit: pageLimit
        )
        canFetchMore = response.count == pageLimit
        currentPage = page
        return response
    }

    func fetchInitialSearchResult(query: String, quarter: Quarter, predicates: [SearchPredicate]) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        let lectures = try await fetchSearchResult(query: query, at: 0, quarter: quarter, predicates: predicates)
        searchQuery = query
        self.quarter = quarter
        self.predicates = predicates
        searchState = .searched(lectures)
    }

    func fetchMoreSearchResult() async throws {
        guard !isLoading, canFetchMore, let quarter, let predicates else { return }
        guard case .searched(let currentLectures) = searchState else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        let lectures = try await fetchSearchResult(
            query: searchQuery,
            at: currentPage + 1,
            quarter: quarter,
            predicates: predicates
        )
        searchState = .searched(currentLectures + lectures)
    }

    func reset() {
        searchState = .initial
        currentPage = 0
        canFetchMore = true
        searchQuery = ""
        quarter = nil
    }
}
