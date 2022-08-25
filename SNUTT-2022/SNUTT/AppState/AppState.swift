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

    var search = SearchState()
    var timetable = TimetableState()
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
