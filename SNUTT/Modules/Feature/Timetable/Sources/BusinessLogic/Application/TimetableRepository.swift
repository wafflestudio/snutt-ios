//
//  TimetableRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import TimetableInterface

@Spyable
public protocol TimetableRepository: Sendable {
    func fetchTimetable(timetableID: String) async throws -> any Timetable
    func fetchRecentTimetable() async throws -> any Timetable
    func fetchTimetableMetadataList() async throws -> [any TimetableMetadata]
    func updateTimetableTitle(timetableID: String, title: String) async throws -> [any TimetableMetadata]
    func setPrimaryTimetable(timetableID: String) async throws
    func unsetPrimaryTimetable(timetableID: String) async throws
    func copyTimetable(timetableID: String) async throws -> [any TimetableMetadata]
    func deleteTimetable(timetableID: String) async throws -> [any TimetableMetadata]
    func addLecture(timetableID: String, lectureID: String) async throws -> any Timetable
    func removeLecture(timetableID: String, lectureID: String) async throws -> any Timetable
}

public enum TimetableRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableRepository = TimetableRepositorySpy()

    public static let previewValue: any TimetableRepository = {
        let spy = TimetableRepositorySpy()
        spy.fetchRecentTimetableReturnValue = PreviewHelpers.preview(id: "1")
        spy.fetchTimetableMetadataListReturnValue = (1 ... 10).map { PreviewHelpers.previewMetadata(with: "\($0)") }
        spy.fetchTimetableTimetableIDClosure = { id in
            try await Task.sleep(for: .milliseconds(200))
            return PreviewHelpers.preview(id: id)
        }
        return spy
    }()
}

extension DependencyValues {
    public var timetableRepository: any TimetableRepository {
        get { self[TimetableRepositoryKey.self] }
        set { self[TimetableRepositoryKey.self] = newValue }
    }
}
