//
//  DeepLinkHandler.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/27.
//

import Foundation
import UIKit

@MainActor
struct DeepLinkHandler {
    typealias Parameters = [URLQueryItem]

    let dependency: Dependency

    private var appState: AppState {
        dependency.appState
    }

    private var timetableService: TimetableServiceProtocol {
        dependency.timetableService
    }

    private var lectureService: LectureServiceProtocol {
        dependency.lectureService
    }


    struct Dependency {
        let appState: AppState
        let timetableService: TimetableServiceProtocol
        let lectureService: LectureServiceProtocol
    }

    func open(url: URL) async throws {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        switch urlComponents.host {
        case "notifications":
            handleNotification(parameters: urlComponents.queryItems)
        case "vacancy":
            handleVacancy(parameters: urlComponents.queryItems)
        case "friends":
            handleFriends(parameters: urlComponents.queryItems)
        case "timetable-lecture":
            try await handleTimetableLecture(parameters: urlComponents.queryItems)
        case "bookmarks":
            try await handleBookmark(parameters: urlComponents.queryItems)
        default:
            return
        }
    }
}

extension DeepLinkHandler {
    private func handleNotification(parameters _: Parameters?) {
        appState.system.selectedTab = .timetable
        appState.routing.timetableScene.pushToNotification = true
    }

    private func handleVacancy(parameters _: Parameters?) {
        appState.system.selectedTab = .settings
        appState.routing.settingScene.pushToVacancy = true
    }

    private func handleFriends(parameters _: Parameters?) {
        appState.system.selectedTab = .friends
    }

    private func handleTimetableLecture(parameters: Parameters?) async throws {
        guard let timetableId = parameters?["timetableId"],
              let lectureId = parameters?["lectureId"] else { throw STError(.CANT_PROCRESS_DEEPLINK) }
        guard let timetable = try? await timetableService.fetchTimetableData(timetableId: timetableId),
              let lecture = timetable.lectures.first(where: { $0.lectureId == lectureId })
        else { throw STError(.CANT_PROCRESS_DEEPLINK) }
        if !appState.routing.timetableScene.pushToNotification {
            appState.routing.timetableScene.pushToNotification = true
        }
        appState.routing.notificationList.routeToLectureDetail(with: lecture, timetableId: timetableId)
    }

    private func handleBookmark(parameters: Parameters?) async throws {
        guard let yearString = parameters?["year"],
              let semesterString = parameters?["semester"],
              let lectureId = parameters?["lectureId"],
              let year = Int(yearString),
              let semesterInt = Int(semesterString),
              let semester = Semester(rawValue: semesterInt) 
        else { throw STError(.CANT_PROCRESS_DEEPLINK) }
        let quarter = Quarter(year: year, semester: semester)
        let bookmark = try await lectureService.fetchBookmark(quarter: quarter)
        guard let lecture = bookmark.lectures.first(where: { $0.id == lectureId }) 
        else { throw STError(.CANT_PROCRESS_DEEPLINK)}
        if !appState.routing.timetableScene.pushToNotification {
            appState.routing.timetableScene.pushToNotification = true
        }
        appState.routing.notificationList.routeToLectureDetail(with: lecture)
    }
}

extension DeepLinkHandler.Parameters {
    subscript(_ key: String) -> String? {
        first { $0.name == key }?.value
    }
}



