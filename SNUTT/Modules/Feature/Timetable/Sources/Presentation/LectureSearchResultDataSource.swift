//
//  LectureSearchResultDataSource.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Combine
import Dependencies
import Observation
import TimetableInterface

@Observable
@MainActor
class LectureSearchResultDataSource {
    @ObservationIgnored
    @Dependency(\.lectureSearchRepository) private var searchRepository

    private var quarter: Quarter?
    private var searchQuery = ""
    private let pageLimit = 20
    private var currentPage = 0
    private var isLoading = false
    private var canFetchMore = true
    private var predicates: [SearchPredicate]?
    private(set) var searchResults = [any Lecture]()

    private func fetchSearchResult(query: String, at page: Int, quarter: Quarter, predicates: [SearchPredicate]) async throws -> [any Lecture] {
        let offset = pageLimit * page
        let response = try await searchRepository.fetchSearchResult(query: query, quarter: quarter, predicates: predicates, offset: offset, limit: pageLimit)
        if response.count < pageLimit {
            canFetchMore = false
        }
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
        searchResults = lectures
    }

    func fetchMoreSearchResult() async throws {
        guard !isLoading, canFetchMore, let quarter, let predicates else { return }
        isLoading = true
        defer {
            isLoading = false
        }
        let lectures = try await fetchSearchResult(query: searchQuery, at: currentPage + 1, quarter: quarter, predicates: predicates)
        searchResults.append(contentsOf: lectures)
    }

    func reset() {
        searchResults = []
        currentPage = 0
        canFetchMore = true
        searchQuery = ""
        quarter = nil
    }
}
