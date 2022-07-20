//
//  SearchService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/20.
//

import Foundation

protocol SearchServiceProtocol {
    func fetchTags(quarter: Quarter) async throws
    func toggle(_ tag: SearchTag)
    func toggleFilterSheet()
}

struct SearchService: SearchServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var searchRepository: SearchRepositoryProtocol {
        webRepositories.searchRepository
    }
    
    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }
    
    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }
    
    func fetchTags(quarter: Quarter) async throws {
        // TODO: get from userDefault
        let dto = try await searchRepository.fetchTags(quarter: quarter)
        let model = SearchTagList(from: dto)
        DispatchQueue.main.async {
            appState.setting.filterSheetSetting.searchTagList = model
        }
    }
    
    func toggle(_ tag: SearchTag) {
        if let index = filterSheetSetting.selectedTagList.firstIndex(where: { $0.id == tag.id }) {
            filterSheetSetting.selectedTagList.remove(at: index)
            return
        }
        filterSheetSetting.selectedTagList.append(tag)
    }
    
    func toggleFilterSheet() {
        appState.setting.filterSheetSetting.isOpen.toggle()
    }
}

class FakeSearchService: SearchServiceProtocol {
    func fetchTags(quarter: Quarter) async throws {}
    func toggle(_ tag: SearchTag) {}
    func toggleFilterSheet() {}
}
