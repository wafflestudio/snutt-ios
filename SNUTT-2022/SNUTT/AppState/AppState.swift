//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI

class AppState: ObservableObject {
    @Published var currentUser = CurrentUser()
    @Published var currentTimetable = CurrentTimetable()
    @Published var setting = Setting()
    @Published var system = System()

    @Published var selectedTab: SelectedTab = .timetable
}

extension AppState {
    enum SelectedTab {
        case timetable
        case search
        case review
        case settings
    }

    enum State {
        case error
        case success
    }
}

extension AppState {
    struct CurrentUser {
        // var user = User()             // User Model 생성 후 주석 해제
        var token: String?
        var userId: String?
        var registeredFCMToken: String?
    }
}

extension AppState {
    struct CurrentTimetable {
        var timetable = Timetable()

        // for test(will be removed)
        let lectures = [Lecture(id: 1), Lecture(id: 2), Lecture(id: 3)]
        var dummyLecture: Lecture {
            lectures[0]
        }
    }
}

// 현재 환경설정 관련 정보(STDefaults)
extension AppState {
    struct Setting {
        var autoFit: Bool = true
        var dayRange: [Int] = [0, 4]
        var timeRange: [Double] = [0.0, 14.0]
        var shouldShowBadge: Bool = false
        var appVersion: String?
        var apiKey: String?
        var shouldDeleteFCMInfos: String? // STFCMInfoList
        var colorList: String? // STColorList
        var snuevWebUrl: String?
    }
}

// 시스템 상태
extension AppState {
    struct System {
        var showActivityIndicator = false
        var state: State = .success
    }
}

// if needed
// extension AppState: Equatable {
//    static func == (lhs: AppState, rhs: AppState) -> Bool {
//        //return lhs.currentTimetable == rhs.currentTimetable
//        return true
//    }
// }

/// For demo purpose. To be removed.
class DummyAppState {
    static let shared = DummyAppState()

    let lectures = [
        Lecture(id: 1, title: "컴파일러", instructor: "전병곤", timePlaces: [
            TimePlace(day: Weekday(rawValue: 1)!, start: 5.5, len: 1.5, place: "302-123"),
            TimePlace(day: Weekday(rawValue: 3)!, start: 3.15, len: 1.5, place: "302-123"),
            TimePlace(day: Weekday(rawValue: 3)!, start: 4.70, len: 1.5, place: "302-123"),
        ]),
        Lecture(id: 2, title: "컴퓨터구조", instructor: "김진수", timePlaces: [
            TimePlace(day: Weekday(rawValue: 2)!, start: 7.5, len: 1.5, place: "302-123"),
            TimePlace(day: Weekday(rawValue: 4)!, start: 7.5, len: 1.5, place: "302-123"),
        ]),
    ]

    var dummyLecture: Lecture {
        lectures[0]
    }
}
