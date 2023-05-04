//
//  TimetableRepositoryTests.swift
//  SNUTTTests
//
//  Created by Jinsup Keum on 2022/07/08.
//

import Alamofire
@testable import SNUTT
import XCTest

class TimetableRepositoryTests: XCTestCase {
    var repository: TimetableRepository!

    let testTimetableName = "Timetable_\(TestUtils.randomString(length: 5))"
    var testTimetable: TimetableMetadataDto?

    override func setUp() async throws {
        repository = TimetableRepository(session: await .test)
        let timetables = try await repository.createTimetable(title: testTimetableName, year: 2022, semester: 1)
        testTimetable = timetables.first(where: { $0.title == testTimetableName })!
    }

    override func tearDown() async throws {
        let _ = try await repository.deleteTimetable(withTimetableId: testTimetable!._id)
    }

    func testUpdateTimetableTitle() async throws {
        let newTitle = "\(testTimetableName)_RENAMED"
        guard let testTimetable = testTimetable else {
            return
        }

        let _ = try await repository.updateTimetableTitle(withTimetableId: testTimetable._id, withTitle: newTitle)

        let updatedTimetable = try await repository.fetchTimetable(withTimetableId: testTimetable._id)

        XCTAssertEqual(newTitle, updatedTimetable.title)
    }

    func testCopyTimetable() async throws {
        let oldList = try await repository.fetchTimetableList()
        var newList = try await repository.copyTimetable(withTimetableId: testTimetable!._id)
        XCTAssertEqual(oldList.count + 1, newList.count)

        // cleanup
        newList.removeAll(where: { new in oldList.contains(where: { old in new._id == old._id }) })
        let copiedTimetable = newList.first!
        let _ = try await repository.deleteTimetable(withTimetableId: copiedTimetable._id)
    }

    func testUpdateTimetableTheme() async throws {
        let newThemeIndex = 2

        let _ = try await repository.updateTimetableTheme(withTimetableId: testTimetable!._id, withTheme: newThemeIndex)

        let updatedTimetable = try await repository.fetchTimetable(withTimetableId: testTimetable!._id)

        XCTAssertEqual(newThemeIndex, updatedTimetable.theme)
    }
}
