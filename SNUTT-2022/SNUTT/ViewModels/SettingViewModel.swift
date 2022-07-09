//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel {
    var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    private var appState: AppState {
        container.appState
    }

    var currentUser: User {
        appState.currentUser
    }

    func updateCurrentUser(user: User) {
        appState.currentUser = user
    }

}
