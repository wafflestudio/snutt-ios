//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

class AppState {
    static let of = AppState()
    let menuSheet = MenuSheetStates()
    let filterSheet = FilterSheetStates()
}

class MenuSheetStates: ObservableObject {
    @Published var isOpen: Bool = false
}

class FilterSheetStates: ObservableObject {
    @Published var isOpen: Bool = false
}

/// For demo purpose. To be removed.
class DummyAppState {
    static let shared = DummyAppState()
    let lectures = [Lecture(id: 1), Lecture(id: 2), Lecture(id: 3), Lecture(id: 11), Lecture(id: 21), Lecture(id: 31), Lecture(id: 12), Lecture(id: 22), Lecture(id: 32)]
    var dummyLecture: Lecture {
        lectures[0]
    }
}
