//
//  EvaluationSearchViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation

@MainActor
@Observable
final class EvaluationSearchViewModel {
    /// What the search surface shows below the search field.
    enum ResultState: Equatable {
        /// Nothing has been searched yet for the current input.
        case idle
        case loading
        case loaded(SearchResults)
    }

    struct SearchResults: Equatable {
        let query: LectureSearchQuery
        var results: [LectureSearchResult]
        /// The page to request next, or `nil` when every page has been loaded.
        var nextPage: Int?
    }

    var queryText = "" {
        didSet {
            guard queryText != oldValue, !currentQuery.isSearchable else { return }
            resultState = .idle
        }
    }

    var isPresented = false
    private(set) var filterTags: [SearchTag]
    private(set) var resultState: ResultState = .idle

    @ObservationIgnored
    @Dependency(\.evaluationRepository) private var repository

    @ObservationIgnored
    @Dependency(\.evaluationSearchFilterStore) private var filterStore

    @ObservationIgnored
    private var isLoadingMore = false

    init() {
        @Dependency(\.evaluationSearchFilterStore) var filterStore
        filterTags = filterStore.loadTags()
    }

    var currentQuery: LectureSearchQuery {
        LectureSearchQuery(text: queryText, tags: filterTags)
    }

    func search() async throws {
        let query = currentQuery
        guard query.isSearchable else {
            resultState = .idle
            return
        }
        resultState = .loading
        do {
            let page = try await repository.searchLectures(query: query, page: 0)
            guard currentQuery == query else { return }
            resultState = .loaded(
                SearchResults(query: query, results: page.results, nextPage: page.isLast ? nil : page.page + 1)
            )
        } catch {
            if currentQuery == query { resultState = .idle }
            throw error
        }
    }

    /// Pagination is driven by scrolling, so failures stay silent and the next scroll retries.
    func loadMoreIfNeeded(after result: LectureSearchResult) async {
        guard case .loaded(let searchResults) = resultState,
            let nextPage = searchResults.nextPage,
            searchResults.results.suffix(5).contains(where: { $0.id == result.id }),
            !isLoadingMore
        else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        guard let page = try? await repository.searchLectures(query: searchResults.query, page: nextPage),
            case .loaded(var currentResults) = resultState,
            currentResults.query == searchResults.query
        else { return }
        let existingIDs = Set(currentResults.results.map(\.id))
        currentResults.results += page.results.filter { !existingIDs.contains($0.id) }
        currentResults.nextPage = page.isLast ? nil : page.page + 1
        resultState = .loaded(currentResults)
    }

    /// Applies filters and runs the search immediately, since filters only affect search results.
    func applyFilterTags(_ tags: [SearchTag]) async throws {
        updateFilterTags(tags)
        isPresented = true
        try await search()
    }

    func removeFilterTag(_ tag: SearchTag) async throws {
        updateFilterTags(filterTags.filter { $0 != tag })
        try await search()
    }

    private func updateFilterTags(_ tags: [SearchTag]) {
        filterTags = tags
        filterStore.saveTags(tags)
    }
}
