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
    
    var currentTimetable: Timetable {
        state.currentTimetable
    }
    
    func updateTimetable(timeTable: Timetable) {
        state.currentTimetable = timeTable
    }
    
    init(appState: AppState) {
        self.state = appState
    }
}
