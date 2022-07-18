//
//  FilterSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class FilterSheetViewModel {
    var container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    private var appState: AppState {
        container.appState
    }

    var filterSheetSetting: FilterSheetSetting {
        appState.setting.filterSheetSetting
    }
}
