//
//  ContentViewModel+URLScheme.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Foundation
import Friends
import Timetable

extension ContentViewModel {
    typealias QueryParameters = [URLQueryItem]

    func handleURLScheme(_ url: URL) async throws {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        switch urlComponents.host {
        case "notifications":
            selectedTab = .timetable
            timetableRouter.navigationPaths = [.notificationList]
            return
        case "vacancy":
            return
        case "friends":
            selectedTab = .friends
            return
        case "timetable-lecture":
            try await handleTimetableLectureScheme(urlComponents.queryItems)
        case "bookmarks":
            try await handleBookmarkScheme(urlComponents.queryItems)
            return
        case "kakaolink":
            handleKakaoLinkScheme(urlComponents.queryItems)
            return
        default:
            return
        }
    }

    private func handleTimetableLectureScheme(_ parameters: QueryParameters?) async throws {
        guard let timetableID = parameters?["timetableId"],
            let lectureID = parameters?["lectureId"]
        else { throw LocalizedErrorCode.deeplinkProcessFailed }
        let timetable = try await timetableRepository.fetchTimetable(timetableID: timetableID)
        guard let lecture = timetable.lectures.first(where: { $0.lectureID == lectureID })
        else { throw LocalizedErrorCode.deeplinkLectureNotFound }
        selectedTab = .timetable
        timetableRouter.navigationPaths = [.notificationList, .lectureDetail(lecture)]
        analyticsLogger.logScreen(
            Timetable.AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .notification))
        )
    }

    private func handleBookmarkScheme(_: QueryParameters?) async throws {
        selectedTab = .search
        lectureSearchRouter.searchDisplayMode = .bookmark
    }

    private func handleKakaoLinkScheme(_ parameters: QueryParameters?) {
        guard parameters?["type"] == "add-friend-kakao",
            let requestToken = parameters?["requestToken"]
        else { return }

        selectedTab = .friends
        NotificationCenter.default.post(
            name: .kakaoFriendRequest,
            object: nil,
            userInfo: ["requestToken": requestToken]
        )
    }
}

extension ContentViewModel.QueryParameters {
    subscript(_ key: String) -> String? {
        first { $0.name == key }?.value
    }
}
