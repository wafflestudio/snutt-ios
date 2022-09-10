//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class SearchSceneViewModel: BaseViewModel, ObservableObject {
    @Published private var _currentTimetable: Timetable?
    @Published private var _timetableConfig: TimetableConfiguration = .init()
    @Published private var _selectedLecture: Lecture?
    @Published private var _searchText: String = ""
    @Published private var _isFilterOpen: Bool = false
    @Published var searchResult: [Lecture] = []
    @Published var selectedTagList: [SearchTag] = []
    @Published var isLoading: Bool = false

    var searchText: String {
        get { _searchText }
        set { services.searchService.setSearchText(newValue) }
    }

    var isFilterOpen: Bool {
        get { _isFilterOpen }
        set { services.searchService.setIsFilterOpen(newValue) }
    }

    var selectedLecture: Lecture? {
        get { _selectedLecture }
        set { services.searchService.setSelectedLecture(newValue) }
    }

    var currentTimetableWithSelection: Timetable? {
        _currentTimetable?.withSelectedLecture(_selectedLecture)
    }

    var timetableConfigWithAutoFit: TimetableConfiguration {
        _timetableConfig.withAutoFitEnabled()
    }

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$_currentTimetable)
        appState.timetable.$configuration.assign(to: &$_timetableConfig)
        appState.search.$selectedLecture.assign(to: &$_selectedLecture)
        appState.search.$searchText.assign(to: &$_searchText)
        appState.search.$isFilterOpen.assign(to: &$_isFilterOpen)
        appState.search.$searchResult.assign(to: &$searchResult)
        appState.search.$isLoading.assign(to: &$isLoading)
        appState.search.$selectedTagList.assign(to: &$selectedTagList)
    }

    private var searchState: SearchState {
        appState.search
    }

    private var timetableState: TimetableState {
        appState.timetable
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

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func fetchMoreSearchResult() async {
        do {
            try await services.searchService.fetchMoreSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }
}
