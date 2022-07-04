//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel {
    var appState: AppState

    var currentUser: User {
        appState.currentUser
    }

    func updateCurrentUser(user: User) {
        appState.currentUser = user
    }

    init(appState: AppState) {
        self.appState = appState
    }
}
