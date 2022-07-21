//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine
import SwiftUI

class SearchSceneViewModel: BaseViewModel, ObservableObject {
    
    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }

    var timetableSetting: TimetableSetting {
        appState.setting.timetableSetting
    }
    
    var searchResult: [Lecture] {
        filterSheetSetting.searchResult
    }
    
    func toggleFilterSheet() {
        if appState.setting.filterSheetSetting.searchTagList == nil {
            return
        }
        services.searchService.toggleFilterSheet()
    }
    
    func fetchTags() async {
        if appState.setting.filterSheetSetting.searchTagList != nil {
            return
        }
        guard let currentTimetable = timetableSetting.current else { return }
        do {
            try await services.searchService.fetchTags(quarter: currentTimetable.quarter)
        } catch {
            // TODO: handle error
        }
    }
    
    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            // TODO: handle error
        }
    }
    
    func fetchMoreSearchResult() async {
        do {
            try await services.searchService.fetchMoreSearchResult()
        } catch {
            // TODO: handle error
        }
    }
    
    func getSelectedTagList() -> [SearchTag] {
        return filterSheetSetting.selectedTagList
    }
    
    var selectedCount: Int {
        return getSelectedTagList().count
    }
    
    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }
}
