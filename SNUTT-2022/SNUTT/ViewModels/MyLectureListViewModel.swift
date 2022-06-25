//
//  MyLectureListViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

class MyLectureListViewModel: ObservableObject {
    var currentTimetable = AppState.of.currentTimetable

    func updateTimetable(timeTable: AppState.CurrentTimetable) {
        AppState.of.currentTimetable = timeTable
    }
}
