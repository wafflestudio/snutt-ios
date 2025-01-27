//
//  SearchService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation
import SwiftUI

@MainActor
protocol SearchServiceProtocol: Sendable {
    func toggle(_ tag: SearchTag)
    func deselectTag(_ tag: SearchTag)
    func selectTimeRangeTag()
    func fetchTags(quarter: Quarter) async throws
    func fetchInitialSearchResult() async throws
    func fetchMoreSearchResult() async throws
    func updateSelectedTimeRange(to range: [SearchTimeMaskDto])
    func setIsFilterOpen(_ value: Bool)
    func setSearchText(_ value: String)
    func setSelectedLecture(_ value: Lecture?)
    func initializeSearchState()
    func getBookmark() async throws
    func setSearchDisplayMode(_ mode: SearchDisplayMode)
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

    func setLoading(_ value: Bool) {
        searchState.isLoading = value
    }

    func initializeSearchState() {
        searchState.selectedLecture = nil
        searchState.selectedTagList = []
        searchState.searchResult = nil
        searchState.searchText = ""
        searchState.displayMode = .search
    }

    func fetchTags(quarter: Quarter) async throws {
        // TODO: get from userDefault
        if let _ = searchState.searchTagList {
            return
        }
        let dto = try await searchRepository.fetchTags(quarter: quarter)
        let model = SearchTagList(from: dto)
        appState.search.searchTagList = model
    }

    private func _fetchSearchResult() async throws {
        guard let currentTimetable = timetableState.current else { return }
        let tagList = searchState.selectedTagList
        let timeList = tagList.contains(where: { $0.type == .time && TimeType(rawValue: $0.text) == .range }) ? searchState.selectedTimeRange : nil
        let excludedTimeList = tagList.contains(where: { $0.type == .time && TimeType(rawValue: $0.text) == .empty }) ? currentTimetable.timeMask : nil
        let offset = searchState.perPage * searchState.pageNum
        let dtos = try await searchRepository.fetchSearchResult(query: searchState.searchText,
                                                                quarter: currentTimetable.quarter,
                                                                tagList: tagList,
                                                                timeList: timeList,
                                                                excludedTimeList: excludedTimeList,
                                                                offset: offset,
                                                                limit: searchState.perPage)
        let models: [Lecture] = dtos.map { Lecture(from: $0) }
        searchState.searchResult = offset == 0 ? models : (searchState.searchResult ?? []) + models
    }

    func fetchInitialSearchResult() async throws {
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

    func toggle(_ tag: SearchTag) {
        if let index = searchState.selectedTagList.firstIndex(where: { $0.id == tag.id }) {
            searchState.selectedTagList.remove(at: index)
            return
        }
        if tag.type == .sortCriteria {
            searchState.selectedTagList.removeAll(where: { $0.type == .sortCriteria })
        }
        searchState.selectedTagList.append(tag)
    }

    /// We need a separate method that only deselects tags.
    func deselectTag(_ tag: SearchTag) {
        if let index = searchState.selectedTagList.firstIndex(where: { $0.id == tag.id }) {
            searchState.selectedTagList.remove(at: index)
            return
        }
    }

    func selectTimeRangeTag() {
        guard let tag = searchState.searchTagList?.tagList.first(where: { $0.type == .time && $0.text == TimeType.range.rawValue }) else {
            return
        }
        if searchState.selectedTagList.firstIndex(where: { $0.id == tag.id }) == nil {
            searchState.selectedTagList.append(tag)
        }
    }

    func updateSelectedTimeRange(to range: [SearchTimeMaskDto]) {
        searchState.selectedTimeRange = range
    }

    func setIsFilterOpen(_ value: Bool) {
        searchState.isFilterOpen = value
    }

    func setSearchDisplayMode(_ mode: SearchDisplayMode) {
        searchState.displayMode = mode
    }

    func setSelectedLecture(_ value: Lecture?) {
        searchState.selectedLecture = value
    }

    func setSearchText(_ value: String) {
        searchState.searchText = value
    }

    func getBookmark() async throws {
        guard let currentTimetable = appState.timetable.current else { return }
        let dto = try await lectureRepository.getBookmark(quarter: currentTimetable.quarter)
        let bookmark = Bookmark(from: dto)
        appState.timetable.bookmark = bookmark
    }

    private var lectureRepository: LectureRepositoryProtocol {
        webRepositories.lectureRepository
    }
}

class FakeSearchService: SearchServiceProtocol {
    func toggle(_: SearchTag) {}
    func deselectTag(_: SearchTag) {}
    func selectTimeRangeTag() {}
    func fetchTags(quarter _: Quarter) async throws {}
    func fetchInitialSearchResult() async throws {}
    func fetchMoreSearchResult() async throws {}
    func updateSelectedTimeRange(to _: [SearchTimeMaskDto]) {}
    func setIsFilterOpen(_: Bool) {}
    func toggleFilterSheet() {}
    func setSearchText(_: String) {}
    func setSelectedLecture(_: Lecture?) {}
    func initializeSearchState() {}
    func getBookmark() async throws {}
    func setSearchDisplayMode(_: SearchDisplayMode) {}
}
