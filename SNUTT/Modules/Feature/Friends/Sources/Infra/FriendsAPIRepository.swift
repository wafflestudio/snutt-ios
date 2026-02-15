//
//  FriendsAPIRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import FoundationUtility
import ThemesInterface
import TimetableInterface

struct FriendsAPIRepository: FriendsRepository {
    @Dependency(\.apiClient) private var apiClient

    init() {}

    func getFriends(state: FriendState) async throws -> [Friend] {
        let response = try await apiClient.getFriends(query: .init(state: state.rawValue)).ok.body.json
        return response.content.map { dto in
            Friend(
                id: dto.id,
                userId: dto.userId,
                nickname: dto.nickname.nickname,
                tag: dto.nickname.tag,
                displayName: dto.displayName,
            )
        }
    }

    func requestFriend(nickname: String) async throws {
        let request = Components.Schemas.FriendRequest(nickname: nickname)
        _ = try await apiClient.requestFriend(body: .json(request))
    }

    func acceptFriend(friendID: String) async throws {
        _ = try await apiClient.acceptFriend(path: .init(friendId: friendID)).ok
    }

    func declineFriend(friendID: String) async throws {
        _ = try await apiClient.declineFriend(path: .init(friendId: friendID)).ok
    }

    func breakFriend(friendID: String) async throws {
        _ = try await apiClient.breakFriend(path: .init(friendId: friendID)).ok
    }

    func updateFriendDisplayName(friendID: String, displayName: String) async throws {
        let updateRequest = Components.Schemas.UpdateFriendDisplayNameRequest(displayName: displayName)
        _ = try await apiClient.updateFriendDisplayName(
            path: .init(friendId: friendID),
            body: .json(updateRequest)
        ).ok
    }

    // MARK: - Friend's Timetable

    func getFriendCoursebooks(friendID: String) async throws -> [Quarter] {
        let coursebooks = try await apiClient.getCoursebooks(path: .init(friendId: friendID)).ok.body.json
        return coursebooks.map { dto in
            let semester = Semester(rawValue: Int(dto.semester.rawValue)) ?? .first
            return Quarter(year: Int(dto.year), semester: semester)
        }
    }

    func getFriendPrimaryTable(friendID: String, quarter: Quarter) async throws -> Timetable {
        let timetableDto = try await apiClient.getPrimaryTable(
            path: .init(friendId: friendID),
            query: .init(
                semester: require(.init(rawValue: quarter.semester.rawValue)),
                year: Int32(quarter.year)
            )
        ).ok.body.json

        return try timetableDto.toTimetable()
    }

    // MARK: - Kakao Link

    func generateFriendLink() async throws -> FriendRequestLink {
        let response = try await apiClient.generateFriendLink().ok.body.json
        return FriendRequestLink(requestToken: response.requestToken)
    }

    func acceptFriendByLink(requestToken: String) async throws -> Friend {
        let response = try await apiClient.acceptFriendByLink(
            path: .init(requestToken: requestToken)
        ).ok.body.json
        return Friend(
            id: response.id,
            userId: response.userId,
            nickname: response.nickname.nickname,
            tag: response.nickname.tag,
            displayName: response.displayName
        )
    }
}

extension Components.Schemas.TimetableDto {
    fileprivate func toTimetable() throws -> Timetable {
        let semester = try require(Semester(rawValue: Int(semester.rawValue)))
        let quarter = Quarter(year: Int(year), semester: semester)
        let builtInTheme: Theme =
            switch theme {
            case ._0: .snutt
            case ._1: .fall
            case ._2: .modern
            case ._3: .cherryBlossom
            case ._4: .ice
            case ._5: .lawn
            }

        let themeType: ThemeType =
            if let themeId {
                .customTheme(themeID: themeId)
            } else {
                .builtInTheme(builtInTheme)
            }

        return Timetable(
            id: try require(id),
            title: title,
            quarter: quarter,
            lectures: try lectures.map { try $0.toLecture() },
            userID: userId,
            theme: themeType,
            isPrimary: isPrimary
        )
    }
}

extension Components.Schemas.TimetableLectureDto {
    fileprivate func toLecture() throws -> Lecture {
        let isCustom = courseNumber == nil || courseNumber == ""
        let timePlaces = try classPlaceAndTimes.enumerated().map { index, classTime in
            try classTime.toTimePlace(index: index, isCustom: isCustom)
        }
        let customColor: LectureColor? =
            if colorIndex == 0,
                let fg = color?.fg,
                let bg = color?.bg
            {
                .init(fgHex: fg, bgHex: bg)
            } else {
                nil
            }

        return Lecture(
            id: UUID().uuidString,
            lectureID: nil,
            courseTitle: courseTitle,
            timePlaces: timePlaces,
            lectureNumber: lectureNumber,
            instructor: instructor,
            credit: credit,
            courseNumber: courseNumber,
            department: department,
            academicYear: academicYear,
            remark: remark,
            evLecture: nil,
            colorIndex: Int(colorIndex),
            customColor: customColor,
            classification: classification,
            category: category,
            wasFull: false,
            registrationCount: 0,
            quota: quota.flatMap { Int32($0) },
            freshmenQuota: freshmanQuota.flatMap { Int32($0) }
        )
    }
}

extension Components.Schemas.ClassPlaceAndTimeDto {
    fileprivate func toTimePlace(index: Int, isCustom: Bool) throws -> TimePlace {
        let weekday = try require(Weekday(rawValue: day.rawValue))
        let start = Int(startMinute).quotientAndRemainder(dividingBy: 60)
        let end = Int(endMinute).quotientAndRemainder(dividingBy: 60)
        return .init(
            id: "\(index)-\(start.quotient)-\(start.remainder)-\(place ?? "")-\(isCustom)",
            day: weekday,
            startTime: .init(hour: start.quotient, minute: start.remainder),
            endTime: .init(hour: end.quotient, minute: end.remainder),
            place: place ?? "",
            isCustom: isCustom
        )
    }
}
