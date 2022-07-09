//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation
import SwiftUI

class ReviewViewModel {
    var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    private var appState: AppState {
        container.appState
    }
    
    var currentTimetable: Timetable {
        appState.currentTimetable
    }

    func updateTimetable(timeTable _: Timetable) {
        appState.currentTimetable.lectures = []
    }

}
