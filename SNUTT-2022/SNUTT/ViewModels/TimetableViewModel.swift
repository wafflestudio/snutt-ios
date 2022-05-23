//
//  TimetableViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

class TimetableViewModel: SNUTTViewModel {
    var lectures: [Lecture]  {
        appState.currentTimetable.lectures
    }
    
    // for test(remove and implement otherwise)
    func update() {
        appState.system.showActivityIndicator = !appState.system.showActivityIndicator
    }
}
