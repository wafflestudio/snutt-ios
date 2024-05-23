//
//  TimetableRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Spyable
import Dependencies

@Spyable
public protocol TimetableRepository: Sendable {
    func fetchTimetable(timetableID: String) async throws -> any Timetable
    func fetchRecentTimetable() async throws -> any Timetable
    func fetchTimetableList() async throws -> [any Timetable]
    func updateTimetableTitle(timetableID: String, title: String) async throws -> [any Timetable]
    func setPrimaryTimetable(timetableID: String) async throws -> Void
}

extension TimetableRepositorySpy: @unchecked Sendable {}

public enum TimetableRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableRepository = TimetableRepositorySpy()
}

extension DependencyValues {
    public var timetableRepository: any TimetableRepository {
        get { self[TimetableRepositoryKey.self] }
        set { self[TimetableRepositoryKey.self] = newValue }
    }
}
