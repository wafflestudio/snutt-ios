//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

class AppState {}

/// For demo purpose. To be removed.
class DummyAppState {
    static let shared = DummyAppState()
    let lectures = [ Lecture(id: 1), Lecture(id: 2), Lecture(id: 3)]
    var dummyLecture: Lecture {
        lectures[0]
    }
}
