//
//  FilterSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class FilterSheetViewModel: BaseViewModel {
    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }
    
    var timetableSetting: TimetableSetting {
        appState.setting.timetableSetting
    }
    
    func filterTags(with type: SearchTagType) -> [SearchTag] {
        guard let tagList = filterSheetSetting.searchTagList?.tagList else { return [] }
        return tagList.filter { $0.type == type }
    }
    
    func toggle(_ tag: SearchTag) {
        services.searchService.toggle(tag)
    }
    
    func applySelectedTags() async {
        do {
            try await services.searchService.fetchInitialSearchResult()
        } catch {
            // TODO: handle error
        }
    }
    
    func toggleFilterSheet() {
        filterSheetSetting.isOpen.toggle()
    }
    
    func isSelected(tag: SearchTag) -> Bool {
        return filterSheetSetting.selectedTagList.contains(where: { $0.id == tag.id })
    }
}
