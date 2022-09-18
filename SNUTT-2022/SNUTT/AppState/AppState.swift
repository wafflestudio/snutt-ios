//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI

class AppState {
    var user = UserState()
    var setting = Setting()
    var webView = WebViewState()

    var system = SystemState()
    var search = SearchState()
    var timetable = TimetableState()

    var tab = TabState()
    var menu = MenuState()
}

#if DEBUG
    extension AppState {
        static var preview: AppState {
            let state = AppState()
            state.timetable.current = .preview
            return state
        }
    }
#endif
