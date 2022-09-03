//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class SearchSceneViewModel: BaseViewModel {
    var searchState: SearchState {
        appState.search
    }

    var timetableState: TimetableState {
        appState.timetable
    }

    var searchResult: [Lecture] {
        searchState.searchResult ?? []
    }

    var isLoading: Bool {
        searchState.isLoading
    }
    
    func initializeSearchState() {
        services.searchService.initializeSearchState()
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

    var selectedTagList: [SearchTag] {
        searchState.selectedTagList
    }

    var selectedLecture: Published<Lecture?>.Publisher {
        searchState.$selectedLecture
    }

    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }
    
    func addLecture(lecture: Lecture) async {
        do {
            try await services.lectureService.addLecture(lecture: lecture)
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }
}
