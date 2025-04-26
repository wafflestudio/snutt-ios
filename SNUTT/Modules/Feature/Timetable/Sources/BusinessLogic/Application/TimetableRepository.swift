//
//  TimetableRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import ThemesInterface
import TimetableInterface

@Spyable
public protocol TimetableRepository: Sendable {
    func fetchTimetable(timetableID: String) async throws -> Timetable
    func fetchRecentTimetable() async throws -> Timetable
    func fetchTimetableMetadataList() async throws -> [TimetableMetadata]
    func updateTimetableTitle(timetableID: String, title: String) async throws -> [TimetableMetadata]
    func updateTimetableTheme(timetableID: String, theme: Theme) async throws -> Timetable
    func setPrimaryTimetable(timetableID: String) async throws
    func unsetPrimaryTimetable(timetableID: String) async throws
    func copyTimetable(timetableID: String) async throws -> [TimetableMetadata]
    func deleteTimetable(timetableID: String) async throws -> [TimetableMetadata]
    func addLecture(timetableID: String, lectureID: String) async throws -> Timetable
    func removeLecture(timetableID: String, lectureID: String) async throws -> Timetable
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
