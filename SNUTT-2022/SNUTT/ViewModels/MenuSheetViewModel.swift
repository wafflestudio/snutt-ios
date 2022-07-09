//
//  MenuSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class MenuSheetViewModel {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var menuSheetSetting: MenuSheetSetting {
        appState.setting.menuSheetSetting
    }
}
