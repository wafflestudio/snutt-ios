//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine

class SearchSceneViewModel: ObservableObject {
    var container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    private var appState: AppState {
        container.appState
    }

    @Published var searchText = ""

    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }

    var currentTimetable: Timetable {
        appState.currentTimetable
    }

    var timetableSetting: TimetableSetting {
        appState.setting.timetableSetting
    }

    func toggleFilterSheet() {
        appState.setting.filterSheetSetting.isOpen.toggle()
    }
}
