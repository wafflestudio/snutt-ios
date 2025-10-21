//
//  RoutingState.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/27.
//

import Foundation

@MainActor
class ViewRoutingState {
    @Published var settingScene = SettingScene.RoutingState()
    @Published var timetableScene = TimetableScene.RoutingState()
    @Published var notificationList = NotificationList.RoutingState()
    @Published var bookmarkList = SearchLectureScene.RoutingState()
}

extension SettingScene {
    struct RoutingState {
        var pushToVacancy = false
    }
}

extension TimetableScene {
    struct RoutingState {
        var pushToNotification = false
    }
}

extension SearchLectureScene {
    struct RoutingState {
        var pushToBookmark = false
    }
}

extension NotificationList {
    struct RoutingState {
        var lectureDetailRoutingInfo = LectureDetailRoutingInfo()

        mutating func routeToLectureDetail(with lecture: Lecture, timetableId: String? = nil) {
            var info = LectureDetailRoutingInfo()
            info.pushToLectureDetail = true
            info.lecture = lecture
            info.timetableId = timetableId
            lectureDetailRoutingInfo = info
        }
    }
}

extension NotificationList.RoutingState {
    struct LectureDetailRoutingInfo {
        var pushToLectureDetail = false
        var lecture: Lecture?
        var timetableId: String?
    }
}
