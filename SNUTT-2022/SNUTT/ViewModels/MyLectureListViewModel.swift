//
//  MyLectureListViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import Foundation
import SwiftUI

class MyLectureListViewModel {
    var appState: AppState

    var currentTimetable: Timetable {
        appState.currentTimetable
    }

    func updateTimetable(timeTable: Timetable) {
        appState.currentTimetable = timeTable
    }

    init(appState: AppState) {
        self.appState = appState
    }
}
