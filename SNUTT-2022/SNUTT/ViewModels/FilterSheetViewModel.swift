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
    @Published private var _isFilterOpen: Bool = false
    
    var isFilterOpen: Bool {
        get { _isFilterOpen }
        set { setIsFilterOpen(newValue) }
    }
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        appState.search.$selectedTagList.assign(to: &$selectedTagList)
        appState.search.$searchTagList.assign(to: &$searchTagList)
        appState.search.$isFilterOpen.assign(to: &$_isFilterOpen)
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
            services.globalUIService.presentErrorAlert(error: error)
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
