//
//  FilterSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import SwiftUI

class FilterSheetViewModel: BaseViewModel, ObservableObject {
    @Published var selectedTagList: [SearchTag] = []
    @Published var searchTagList: SearchTagList?
    @Published var pinnedTagList: [SearchTag] = []
    @Published private var _selectedTimeRange: [SearchTimeMaskDto] = []
    @Published private var _isFilterOpen: Bool = false

    var isFilterOpen: Bool {
        get { _isFilterOpen }
        set {
            _isFilterOpen = newValue
            services.searchService.setIsFilterOpen(newValue)
        }
    }

    var selectedTimeRange: [SearchTimeMaskDto] {
        get { _selectedTimeRange }
        set { services.searchService.updateSelectedTimeRange(to: newValue) }
    }

    var currentTimetable: Timetable? {
        appState.timetable.current
    }

    override init(container: DIContainer) {
        super.init(container: container)

        appState.search.$selectedTagList.assign(to: &$selectedTagList)
        appState.search.$selectedTimeRange.assign(to: &$_selectedTimeRange)
        appState.search.$searchTagList.assign(to: &$searchTagList)
        appState.search.$pinnedTagList.assign(to: &$pinnedTagList)
        appState.search.$isFilterOpen.assign(to: &$_isFilterOpen)
    }

    func filterTags(with type: SearchTagType) -> [SearchTag] {
        guard let tagList = searchTagList?.tagList else { return [] }
        return tagList.filter { $0.type == type }
    }

    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }

    func selectTimeRangeTag() {
        services.searchService.selectTimeRangeTag()
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.globalUIService.presentErrorAlert(error: error)
        }
    }

    func isSelected(tag: SearchTag) -> Bool {
        return appState.search.selectedTagList.contains(where: { $0.id == tag.id })
    }

    func removePin(tag: SearchTag) {
        guard let index = appState.search.pinnedTagList.firstIndex(where: { $0.id == tag.id }) else { return }
        appState.search.pinnedTagList.remove(at: index)
    }
}
