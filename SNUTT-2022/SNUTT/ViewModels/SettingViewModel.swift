//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    @ObservedObject private var state: AppState
    
    var currentUser: AppState.CurrentUser {
        state.currentUser
    }
    
    func updateCurrentUser(user: AppState.CurrentUser) {
        state.currentUser = user
    }
    
    init(appState: AppState) {
        self.state = appState
    }
}
