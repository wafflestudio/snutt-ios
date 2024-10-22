//
//  TimetableRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol TimetableRepository: Sendable {
    func fetchTimetable(timetableID: String) async throws -> any Timetable
    func fetchRecentTimetable() async throws -> any Timetable
    func fetchTimetableList() async throws -> [any Timetable]
    func updateTimetableTitle(timetableID: String, title: String) async throws -> [any Timetable]
    func setPrimaryTimetable(timetableID: String) async throws
}

extension TimetableRepositorySpy: @unchecked Sendable {}

public enum TimetableRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableRepository = TimetableRepositorySpy()
}

public extension DependencyValues {
    var timetableRepository: any TimetableRepository {
        get { self[TimetableRepositoryKey.self] }
        set { self[TimetableRepositoryKey.self] = newValue }
    }
}
