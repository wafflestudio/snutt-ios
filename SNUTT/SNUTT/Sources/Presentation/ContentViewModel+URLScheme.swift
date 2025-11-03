//
//  ContentViewModel+URLScheme.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Foundation
import Friends
import TimetableInterface

extension ContentViewModel {
    typealias QueryParameters = [URLQueryItem]

    func handleURLScheme(_ url: URL) async throws {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        switch urlComponents.host {
        case "notifications":
            selectedTab = .timetable
            notificationCenter.post(NavigateToNotificationsMessage())
            return
        case "vacancy":
            return
        case "friends":
            selectedTab = .friends
            notificationCenter.post(OpenFriendsMenuMessage())
            return
        case "timetable-lecture":
            try await handleTimetableLectureScheme(urlComponents.queryItems)
        case "bookmarks":
            handleBookmarkScheme(urlComponents.queryItems)
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
        selectedTab = .timetable
        notificationCenter.post(
            NavigateToLectureMessage(timetableID: timetableID, lectureID: lectureID)
        )
    }

    private func handleBookmarkScheme(_: QueryParameters?) {
        selectedTab = .search
        notificationCenter.post(NavigateToBookmarkMessage())
    }

    private func handleKakaoLinkScheme(_ parameters: QueryParameters?) {
        guard parameters?["type"] == "add-friend-kakao",
            let requestToken = parameters?["requestToken"]
        else { return }

        selectedTab = .friends
        notificationCenter.post(KakaoFriendRequestMessage(requestToken: requestToken))
    }
}

extension ContentViewModel.QueryParameters {
    subscript(_ key: String) -> String? {
        first { $0.name == key }?.value
    }
}
