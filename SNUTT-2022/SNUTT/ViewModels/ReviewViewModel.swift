//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation
import SwiftUI

class ReviewViewModel {
    var appState: AppState
    
    var currentTimetable: Timetable {
        appState.currentTimetable
    }

    func updateTimetable(timeTable: Timetable) {
        appState.currentTimetable.lectures = []
    }
    
    init(appState: AppState) {
        self.appState = appState
    }
}
