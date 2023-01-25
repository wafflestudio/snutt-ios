//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class SearchSceneViewModel: TransculentListViewModel {
    @Published private var _searchText: String = ""
    @Published private var _isFilterOpen: Bool = false
    @Published var searchResult: [Lecture]? = nil
    @Published var selectedTagList: [SearchTag] = []

    var searchText: String {
        get { _searchText }
        set { services.searchService.setSearchText(newValue) }
    }

    var isFilterOpen: Bool {
        get { _isFilterOpen }
        set { services.searchService.setIsFilterOpen(newValue) }
    }
    
    override init(container: DIContainer) {
        super.init(container: container)

        appState.search.$searchText.assign(to: &$_searchText)
        appState.search.$isFilterOpen.assign(to: &$_isFilterOpen)
        appState.search.$searchResult.assign(to: &$searchResult)
        appState.search.$selectedTagList.assign(to: &$selectedTagList)
    }

    func fetchTags() async {
        if appState.search.searchTagList != nil {
            return
        }
        guard let currentTimetable = timetableState.current else { return }
        do {
            try await services.searchService.fetchTags(quarter: currentTimetable.quarter)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func initializeSearchState() {
        services.searchService.initializeSearchState()
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func deselectTag(_ tag: SearchTag) {
        services.searchService.deselectTag(tag)
    }

    private var searchState: SearchState {
        appState.search
    }

    private var timetableState: TimetableState {
        appState.timetable
    }
}
