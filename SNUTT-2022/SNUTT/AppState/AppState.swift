//
//  AppState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Combine
import SwiftUI

class AppState {
    static var of: AppState = AppState()
    var currentUser = CurrentUser()
    var currentTimetable = CurrentTimetable()
    var setting = Setting()
    var timetableSetting = DrawingSetting()
    var system = System()
}

extension AppState {
    
    enum TabType: String {
        case timetable
        case search
        case review
        case settings
        
        var onImageName: String {
            "tab.\(rawValue).on"
        }

        var offImageName: String {
            "tab.\(rawValue).off"
        }
    }

    enum State {
        case error
        case success
    }
}

extension AppState {
    class CurrentUser: ObservableObject {
        // var user = User()             // User Model 생성 후 주석 해제
        var token: String?
        var userId: String?
        var registeredFCMToken: String?
    }
}

extension AppState {
    class CurrentTimetable: ObservableObject {
        var timetable = Timetable()

        // for test(will be removed)
        @Published var lectures = [
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
    }
}

// 현재 환경설정 관련 정보(STDefaults)
extension AppState {
    class Setting: ObservableObject {
        var autoFit: Bool = true
        var dayRange: [Int] = [0, 4]
        var timeRange: [Double] = [0.0, 14.0]
        var shouldShowBadge: Bool = false
        var appVersion: String?
        var apiKey: String?
        var shouldDeleteFCMInfos: String? // STFCMInfoList
        var colorList: String? // STColorList
        var snuevWebUrl: String?

        var drawing: DrawingSetting = .init()
    }

    class DrawingSetting: ObservableObject {
        @Published var minHour: Int = 8
        @Published var maxHour: Int = 19

        @Published var visibleWeeks: [Weekday] = [.mon, .tue, .wed, .thu, .fri]

        var hourCount: Int {
            maxHour - minHour + 1
        }

        var weekCount: Int {
            visibleWeeks.count
        }
    }
}

// 시스템 상태
extension AppState {
    class System: ObservableObject {
        @Published var showActivityIndicator = false
        @Published var state: State = .success
        @Published var selectedTab: TabType = .timetable
    }
}
