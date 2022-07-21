//
//  SearchService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

protocol SearchServiceProtocol {
    func toggle(_ tag: SearchTag)
    func toggleFilterSheet()
    func fetchTags(quarter: Quarter) async throws
    func fetchInitialSearchResult() async throws
    func fetchMoreSearchResult() async throws
}

struct SearchService: SearchServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var searchRepository: SearchRepositoryProtocol {
        webRepositories.searchRepository
    }
    
    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }
    
    var timetableSetting: TimetableSetting {
        appState.setting.timetableSetting
    }
    
    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }
    
    func fetchTags(quarter: Quarter) async throws {
        // TODO: get from userDefault
        let dto = try await searchRepository.fetchTags(quarter: quarter)
        let model = SearchTagList(from: dto)
        DispatchQueue.main.async {
            appState.setting.filterSheetSetting.searchTagList = model
        }
    }
    
    private func _fetchSearchResult() async throws {
        guard let currentTimetable = timetableSetting.current else { return }
        let tagList = filterSheetSetting.selectedTagList
        let mask = tagList.contains(where: { $0.type == .etc && EtcType(rawValue: $0.text) == .empty }) ? currentTimetable.reversedTimeMasks : nil
        let offset = filterSheetSetting.perPage * filterSheetSetting.pageNum
        let dtos = try await searchRepository.fetchSearchResult(query: filterSheetSetting.searchText,
                                                                quarter: currentTimetable.quarter,
                                                                tagList: tagList,
                                                                mask: mask,
                                                                offset: offset,
                                                                limit: filterSheetSetting.perPage)
        let models: [Lecture] = dtos.map { Lecture(from: $0) }
        DispatchQueue.main.async {
            self.filterSheetSetting.searchResult = offset == 0 ? models : self.filterSheetSetting.searchResult + models
        }
    }
    
    func fetchInitialSearchResult() async throws {
        filterSheetSetting.pageNum = 0
        try await _fetchSearchResult()
    }
    
    func fetchMoreSearchResult() async throws {
        filterSheetSetting.pageNum += 1
        try await _fetchSearchResult()
    }
    
    func toggle(_ tag: SearchTag) {
        if let index = filterSheetSetting.selectedTagList.firstIndex(where: { $0.id == tag.id }) {
            filterSheetSetting.selectedTagList.remove(at: index)
            return
        }
        filterSheetSetting.selectedTagList.append(tag)
    }
    
    func toggleFilterSheet() {
        appState.setting.filterSheetSetting.isOpen.toggle()
    }
}

class FakeSearchService: SearchServiceProtocol {
    func fetchTags(quarter: Quarter) async throws {}
    func toggle(_ tag: SearchTag) {}
    func toggleFilterSheet() {}
    func fetchInitialSearchResult() async throws {}
    func fetchMoreSearchResult() async throws {}
}
