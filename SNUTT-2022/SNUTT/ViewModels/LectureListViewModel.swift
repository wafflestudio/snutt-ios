//
//  MyLectureListViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class LectureListViewModel {
    var container: DIContainer

    init(container: DIContainer) {
        self.container = container
    }

    private var appState: AppState {
        container.appState
    }

    var currentTimetable: Timetable? {
        appState.timetable.current
    }
}
