//
//  SearchLectureSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/12/18.
//

import Foundation

class SearchLectureSceneViewModel: BaseViewModel, ObservableObject {
    @Published private var _selectedLecture: Lecture?
    @Published private var _currentTimetable: Timetable?
    @Published private var _timetableConfig: TimetableConfiguration = .init()
    @Published private var _searchText: String = ""
    @Published private var _isFilterOpen: Bool = false
    @Published private var _displayMode: SearchDisplayMode = .search

    @Published var searchResult: [Lecture]? = nil
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

    var displayMode: SearchDisplayMode {
        get { _displayMode }
        set { services.searchService.setSearchDisplayMode(newValue) }
    }

    override init(container: DIContainer) {
        super.init(container: container)

        appState.timetable.$current.assign(to: &$_currentTimetable)
        appState.timetable.$configuration.assign(to: &$_timetableConfig)
        appState.search.$selectedLecture.assign(to: &$_selectedLecture)
        appState.search.$isFilterOpen.assign(to: &$_isFilterOpen)
        appState.search.$searchText.assign(to: &$_searchText)
        appState.search.$isLoading.assign(to: &$isLoading)
        appState.search.$searchResult.assign(to: &$searchResult)
        appState.search.$selectedTagList.assign(to: &$selectedTagList)
        appState.search.$displayMode.assign(to: &$_displayMode)
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

    func fetchTags() async {
        if appState.search.searchTagList != nil {
            return
        }
        guard let currentTimetable = appState.timetable.current else { return }
        do {
            try await services.searchService.fetchTags(quarter: currentTimetable.quarter)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func deselectTag(_ tag: SearchTag) {
        services.searchService.deselectTag(tag)
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
}
