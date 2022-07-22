//
//  MenuSheetViewModel.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/05.
//

class MenuSheetViewModel: BaseViewModel {
    var menuSheetSetting: MenuSheetSetting {
        appState.setting.menuSheetSetting
    }
}
