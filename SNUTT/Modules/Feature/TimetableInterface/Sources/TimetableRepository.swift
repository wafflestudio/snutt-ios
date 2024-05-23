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
    func fetchTimetableMetadataList() async throws -> [any TimetableMetadata]
    func updateTimetableTitle(timetableID: String, title: String) async throws -> [any Timetable]
    func setPrimaryTimetable(timetableID: String) async throws
}

public enum TimetableRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableRepository = TimetableRepositorySpy()

    public static let previewValue: any TimetableRepository = {
        let spy = TimetableRepositorySpy()
        spy.fetchRecentTimetableReturnValue = PreviewHelpers.preview(with: "1")
        spy.fetchTimetableMetadataListReturnValue = (1...10).map { PreviewHelpers.previewMetadata(with: "\($0)") }
        spy.fetchTimetableTimetableIDClosure = { id in
            try await Task.sleep(for: .milliseconds(200))
            return PreviewHelpers.preview(with: id)
        }
        return spy
    }()
}

public extension DependencyValues {
    var timetableRepository: any TimetableRepository {
        get { self[TimetableRepositoryKey.self] }
        set { self[TimetableRepositoryKey.self] = newValue }
    }
}
