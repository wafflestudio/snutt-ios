//
//  SettingViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class SettingViewModel: ObservableObject {
    var currentUser = AppState.of.currentUser

    func updateCurrentUser(user: AppState.CurrentUser) {
        AppState.of.currentUser = user
    }
}
