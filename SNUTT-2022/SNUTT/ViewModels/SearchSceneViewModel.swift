//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class SearchSceneViewModel: BaseViewModel, ObservableObject {
    @Published var currentTimetable: Timetable?
    @Published var timetableConfig: TimetableConfiguration = .init()
    @Published var selectedLecture: Lecture?
    @Published var searchText: String = ""
    @Published var isFilterOpen: Bool = false
    @Published var searchResult: [Lecture] = []
    @Published var selectedTagList: [SearchTag] = []
    @Published var isLoading: Bool = false
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        appState.timetable.$current.assign(to: &$currentTimetable)
        appState.timetable.$configuration.assign(to: &$timetableConfig)
        appState.search.$selectedLecture.assign(to: &$selectedLecture)
        appState.search.$searchText.assign(to: &$searchText)
        appState.search.$isFilterOpen.assign(to: &$isFilterOpen)
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

    func toggleFilterSheet() {
        if appState.search.searchTagList == nil {
            return
        }
        services.searchService.toggleFilterSheet()
    }

    func fetchTags() async {
        if appState.search.searchTagList != nil {
            return
        }
        guard let currentTimetable = timetableState.current else { return }
        do {
            try await services.searchService.fetchTags(quarter: currentTimetable.quarter)
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }

    func fetchMoreSearchResult() async {
        do {
            try await services.searchService.fetchMoreSearchResult()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }
    
    func setSearchText(_ val: String) {
        services.searchService.setSearchText(val)
    }
    
    func setIsFilterOpen(_ val: Bool) {
        services.searchService.setIsFilterOpen(val)
    }
    
    func setSelectedLecture(_ val: Lecture?) {
        services.searchService.setSelectedLecture(val)
    }

    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }
}
