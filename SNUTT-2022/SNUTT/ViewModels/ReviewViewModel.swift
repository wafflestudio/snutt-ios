//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation
import SwiftUI

class ReviewViewModel {
    private var state: AppState
    
    var currentTimetable: Timetable {
        state.currentTimetable
    }

    func updateTimetable(timeTable: Timetable) {
        state.currentTimetable.lectures = []
    }
    
    init(appState: AppState) {
        self.state = appState
    }
}
