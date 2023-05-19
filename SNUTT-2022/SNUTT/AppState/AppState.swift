//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI

@MainActor
final class AppState {
    var user = UserState()

    var system = SystemState()
    var search = SearchState()
    var timetable = TimetableState()

    var menu = MenuState()
    var notification = NotificationState()
    var popup = PopupState()
    var review = ReviewState()

    #if DEBUG
        var debug = DebugState()
    #endif
}

#if DEBUG
    extension AppState {
        static var preview: AppState {
            let state = AppState()
            state.timetable.current = .preview
            state.search.selectedTagList = [.init(id: .init(), type: .classification, text: "예시1"), .init(id: .init(), type: .credit, text: "예시2")]
            return state
        }
    }
#endif
