//
//  TimetableRepositoryTests.swift
//  SNUTTTests
//
//  Created by Jinsup Keum on 2022/07/08.
//

import XCTest
import Alamofir

class TimetableRepositoryTests: XCTestCase {
    class Storage: AuthStorage {
        var apiKey: ApiKey = ""
        var accessToken: AccessToken = ""
    }

    let repository = TimetableRepository(session: Session(interceptor: Interceptor(authStorage: Storage()), eventMonitors: [Logger()]))

    func testFetchRecentTimetable() async throws {
        let _ = try await repository.fetchRecentTimetable()
    }

    func testFetchTimetableList() async throws {
        let _ = try await repository.fetchTimetableList()
    }

    func testFetchTimetable() async throws {
        let recentTimetable = try await repository.fetchRecentTimetable()
        let timetableWithId = try await repository.fetchTimetable(withTimetableId: recentTimetable._id)

        XCTAssertEqual(recentTimetable._id, timetableWithId._id)
    }

    func testUpdateTimetableTitle() async throws {
        let newTitle = "Bravo Timetable"

        let recentTimetable = try await repository.fetchRecentTimetable()
        let _ = try await repository.updateTimetableTitle(withTimetableId: recentTimetable._id, withTitle: newTitle)

        let updatedTimetable = try await repository.fetchTimetable(withTimetableId: recentTimetable._id)

        XCTAssertEqual(newTitle, updatedTimetable.title)
    }

    func testCopyTimetable() async throws {
        let recentTimetable = try await repository.fetchRecentTimetable()
        let _ = try await repository.copyTimetable(withTimetableId: recentTimetable._id)
    }

    func updateTimetableTheme() async throws {
        let newThemeIndex = 2

        let recentTimetable = try await repository.fetchRecentTimetable()
        let _ = try await repository.updateTimetableTheme(withTimetableId: recentTimetable._id, withTheme: newThemeIndex)

        let updatedTimetable = try await repository.fetchTimetable(withTimetableId: recentTimetable._id)

        XCTAssertEqual(newThemeIndex, updatedTimetable.theme)
    }
}
