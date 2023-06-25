//
//  RoutingState.swift
//  SNUTT
//
//  Created by user on 2023/05/27.
//

import Foundation

@MainActor
class ViewRoutingState {
    @Published var settingScene = SettingScene.RoutingState()
}


extension SettingScene {
    struct RoutingState {
        var pushToNotification = false
    }
}
