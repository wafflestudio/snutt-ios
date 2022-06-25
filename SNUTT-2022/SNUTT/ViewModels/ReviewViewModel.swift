//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Foundation
import SwiftUI

class ReviewViewModel: ObservableObject {
    var currentTimetable = AppState.of.currentTimetable

    func updateTimetable(timeTable: AppState.CurrentTimetable) {
        AppState.of.currentTimetable = timeTable
    }
}
