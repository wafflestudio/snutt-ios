//
//  SearchService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import SwiftUI

protocol SearchServiceProtocol {
    func toggle(_ tag: SearchTag)
    func deselectTag(_ tag: SearchTag)
    func fetchTags(quarter: Quarter) async throws
    func fetchInitialSearchResult() async throws
    func fetchMoreSearchResult() async throws
    func setIsFilterOpen(_ value: Bool)
    func setSearchText(_ value: String)
    func setSelectedLecture(_ value: Lecture?)
    func initializeSearchState()
}

struct SearchService: SearchServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var searchRepository: SearchRepositoryProtocol {
        webRepositories.searchRepository
    }

    var searchState: SearchState {
        appState.search
    }

    var timetableState: TimetableState {
        appState.timetable
    }

    @MainActor func setLoading(_ value: Bool) {
        searchState.isLoading = value
    }

    @MainActor func initializeSearchState() {
        searchState.selectedLecture = nil
        searchState.selectedTagList = []
        searchState.searchResult = nil
        searchState.searchText = ""
    }

    func fetchTags(quarter: Quarter) async throws {
        // TODO: get from userDefault
        if let _ = searchState.searchTagList {
            return
        }
        let dto = try await searchRepository.fetchTags(quarter: quarter)
        let model = SearchTagList(from: dto)
        await MainActor.run {
            appState.search.searchTagList = model
        }
    }

    private func _fetchSearchResult() async throws {
        guard let currentTimetable = timetableState.current else { return }
        let tagList = searchState.selectedTagList
        let mask = tagList.contains(where: { $0.type == .etc && EtcType(rawValue: $0.text) == .empty }) ? currentTimetable.reversedTimeMasks : nil
        let offset = searchState.perPage * searchState.pageNum
        let dtos = try await searchRepository.fetchSearchResult(query: searchState.searchText,
                                                                quarter: currentTimetable.quarter,
                                                                tagList: tagList,
                                                                mask: mask,
                                                                offset: offset,
                                                                limit: searchState.perPage)
        let models: [Lecture] = dtos.map { Lecture(from: $0) }
        await MainActor.run {
            self.searchState.searchResult = offset == 0 ? models : (self.searchState.searchResult ?? []) + models
        }
    }

    @MainActor func fetchInitialSearchResult() async throws {
        setLoading(true)
        defer {
            setLoading(false)
        }
        searchState.pageNum = 0
        try await _fetchSearchResult()
    }

    func fetchMoreSearchResult() async throws {
        searchState.pageNum += 1
        try await _fetchSearchResult()
    }

    @MainActor func toggle(_ tag: SearchTag) {
        if let index = searchState.selectedTagList.firstIndex(where: { $0.id == tag.id }) {
            searchState.selectedTagList.remove(at: index)
            return
        }
        searchState.selectedTagList.append(tag)
    }

    /// We need a separate method that only deselects tags.
    @MainActor func deselectTag(_ tag: SearchTag) {
        if let index = searchState.selectedTagList.firstIndex(where: { $0.id == tag.id }) {
            searchState.selectedTagList.remove(at: index)
            return
        }
    }

    @MainActor func setIsFilterOpen(_ value: Bool) {
        searchState.isFilterOpen = value
    }

    @MainActor func setSelectedLecture(_ value: Lecture?) {
        searchState.selectedLecture = value
    }

    @MainActor func setSearchText(_ value: String) {
        searchState.searchText = value
    }
}

class FakeSearchService: SearchServiceProtocol {
    func toggle(_: SearchTag) {}
    func deselectTag(_: SearchTag) {}
    func fetchTags(quarter _: Quarter) async throws {}
    func fetchInitialSearchResult() async throws {}
    func fetchMoreSearchResult() async throws {}
    func setIsFilterOpen(_: Bool) {}
    func toggleFilterSheet() {}
    func setSearchText(_: String) {}
    func setSelectedLecture(_: Lecture?) {}
    func initializeSearchState() {}
}
