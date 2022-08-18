//
//  FilterSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class FilterSheetViewModel: BaseViewModel {
    var searchState: SearchState {
        appState.search
    }

    var timetableState: TimetableState {
        appState.timetable
    }

    func filterTags(with type: SearchTagType) -> [SearchTag] {
        guard let tagList = searchState.searchTagList?.tagList else { return [] }
        return tagList.filter { $0.type == type }
    }

    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.appService.presentErrorAlert(error: error)
        }
    }

    func toggleFilterSheet() {
        searchState.isFilterOpen.toggle()
    }

    func isSelected(tag: SearchTag) -> Bool {
        return searchState.selectedTagList.contains(where: { $0.id == tag.id })
    }
}
