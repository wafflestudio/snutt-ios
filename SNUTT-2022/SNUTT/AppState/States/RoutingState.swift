//
//  RoutingState.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/27.
//

import Foundation

@MainActor
class ViewRoutingState {
    @Published var settingScene = SettingScene.RoutingState()
}

extension SettingScene {
    struct RoutingState {
        var pushToNotification = false
        var pushToVacancy = false
    }
}
