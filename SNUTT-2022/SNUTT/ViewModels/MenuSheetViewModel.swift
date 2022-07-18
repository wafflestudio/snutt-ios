//
//  MenuSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class MenuSheetViewModel {
    var container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    private var appState: AppState {
        container.appState
    }

    var menuSheetSetting: MenuSheetSetting {
        appState.setting.menuSheetSetting
    }
}
