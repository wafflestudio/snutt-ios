//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation
import SwiftUI

class ReviewViewModel: ObservableObject {
    @ObservedObject private var state: AppState

    var currentTimetable: AppState.CurrentTimetable {
        state.currentTimetable
    }

    func updateTimetable(timeTable: AppState.CurrentTimetable) {
        state.currentTimetable = timeTable
    }

    init(appState: AppState) {
        state = appState
    }
}
