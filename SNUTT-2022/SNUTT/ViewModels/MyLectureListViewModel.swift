//
//  MyLectureListViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class MyLectureListViewModel: ObservableObject {
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
