//
//  FilterSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class FilterSheetViewModel {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }
}
