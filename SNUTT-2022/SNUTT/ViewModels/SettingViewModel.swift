//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel {
     private var state: AppState
    
    var currentUser: User {
        state.currentUser
    }
    
    func updateCurrentUser(user: User) {
        state.currentUser = user
    }
    
    init(appState: AppState) {
        self.state = appState
    }
}
