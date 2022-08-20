//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI

class AppState {
    var currentUser = User()
    var setting = Setting()
    var system = System()
}

#if DEBUG
    extension AppState {
        static var preview: AppState {
            let state = AppState()
            state.setting.timetableSetting.current = .preview
            return state
        }
    }
#endif
