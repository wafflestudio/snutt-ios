//
//  SearchSceneViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

import Combine

class SearchSceneViewModel: ObservableObject {
    var appState: AppState
    @Published var searchText = ""

    init(appState: AppState) {
        self.appState = appState
    }

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
