//
//  FilterSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Foundation

class FilterSheetViewModel: BaseViewModel, ObservableObject {
    
    @Published var selectedTagList: [SearchTag] = []
    @Published var searchTagList: SearchTagList?
    @Published var isFilterOpen: Bool = false
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        appState.search.$selectedTagList.assign(to: &$selectedTagList)
        appState.search.$searchTagList.assign(to: &$searchTagList)
        appState.search.$isFilterOpen.assign(to: &$isFilterOpen)
    }
    

    func filterTags(with type: SearchTagType) -> [SearchTag] {
        guard let tagList = searchTagList?.tagList else { return [] }
        return tagList.filter { $0.type == type }
    }

    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }

    func fetchInitialSearchResult() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            services.appService.presentErrorAlert(error: error.asSTError)
        }
    }

    func toggleFilterSheet() {
        services.searchService.toggleFilterSheet()
    }
    
    func setIsFilterOpen(_ val: Bool) {
        services.searchService.setIsFilterOpen(val)
    }

    func isSelected(tag: SearchTag) -> Bool {
        return appState.search.selectedTagList.contains(where: { $0.id == tag.id })
    }
}
