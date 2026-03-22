//
//  MainContentViewModel+URLScheme.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Foundation
import Friends
import NotificationsInterface
import SharedUIComponents
import Timetable
import TimetableInterface

#if FEATURE_LECTURE_DIARY
import LectureDiaryInterface
#endif

extension MainContentViewModel {
    typealias QueryParameters = [URLQueryItem]

    func handleURLScheme(_ url: URL) async throws {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        switch urlComponents.host {
        case "notifications":
            notificationCenter.post(NavigateToNotificationsMessage())
        case "vacancy":
            break
        case "friends":
            selectedTab = .friends
            notificationCenter.post(OpenFriendsMenuMessage())
        case "timetable-lecture":
            await handleTimetableLectureScheme(urlComponents.queryItems)
        case "bookmarks":
            handleBookmarkScheme(urlComponents.queryItems)
        #if FEATURE_LECTURE_DIARY
        case "diary":
            handleDiaryScheme(urlComponents.queryItems)
        #endif
        case "kakaolink":
            handleKakaoLinkScheme(urlComponents.queryItems)
        default:
            return
        }
    }

    private func handleTimetableLectureScheme(_ parameters: QueryParameters?) async {
        guard let timetableID = parameters?["timetableId"],
            let lectureID = parameters?["lectureId"]
        else {
            notificationCenter.post(
                .toast(.init(message: TimetableStrings.navigationErrorUnknown))
            )
            return
        }
        selectedTab = .timetable
        notificationCenter.post(
            NavigateToLectureMessage(timetableID: timetableID, lectureID: lectureID)
        )
    }

    private func handleBookmarkScheme(_ parameters: QueryParameters?) {
        guard let yearString = parameters?["year"],
            let semesterString = parameters?["semester"],
            let lectureID = parameters?["lectureId"],
            let year = Int(yearString),
            let semesterInt = Int(semesterString),
            let semester = Semester(rawValue: semesterInt)
        else {
            notificationCenter.post(.toast(.init(message: TimetableStrings.navigationErrorUnknown)))
            return
        }
        selectedTab = .timetable
        notificationCenter.post(
            NavigateToBookmarkLecturePreviewMessage(year: year, semester: semester, lectureID: lectureID)
        )
    }

    #if FEATURE_LECTURE_DIARY
    private func handleDiaryScheme(_ parameters: QueryParameters?) {
        guard let lectureID = parameters?["lectureId"],
            let lectureTitle = parameters?["courseTitle"]
        else {
            notificationCenter.post(.toast(.init(message: TimetableStrings.navigationErrorUnknown)))
            return
        }
        notificationCenter.post(
            NavigateToLectureDiaryMessage(lectureID: lectureID, lectureTitle: lectureTitle)
        )
    }
    #endif

    private func handleKakaoLinkScheme(_ parameters: QueryParameters?) {
        guard parameters?["type"] == "add-friend-kakao",
            let requestToken = parameters?["requestToken"]
        else { return }

        selectedTab = .friends
        notificationCenter.post(KakaoFriendRequestMessage(requestToken: requestToken))
    }
}

extension MainContentViewModel.QueryParameters {
    subscript(_ key: String) -> String? {
        first { $0.name == key }?.value
    }
}
