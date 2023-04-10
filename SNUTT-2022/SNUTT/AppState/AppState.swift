//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI

class AppState {
    @MainActor var user = UserState()

    @MainActor var system = SystemState()
    @MainActor var search = SearchState()
    @MainActor var timetable = TimetableState()

    var menu = MenuState()
    var notification = NotificationState()
    var popup = PopupState()
    var review = ReviewState()
}

#if DEBUG
    extension AppState {
        @MainActor static var preview: AppState {
            let state = AppState()
            state.timetable.current = .preview
            state.search.selectedTagList = [.init(id: .init(), type: .classification, text: "예시1"), .init(id: .init(), type: .credit, text: "예시2")]
            return state
        }
    }
#endif
