//
//  TimetableRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import ThemesInterface
import TimetableInterface

@Spyable
public protocol TimetableRepository: Sendable {
    func fetchTimetable(timetableID: TimetableID) async throws -> Timetable
    func fetchRecentTimetable() async throws -> Timetable
    func fetchTimetableMetadataList() async throws -> [TimetableMetadata]
    func updateTimetableTitle(timetableID: TimetableID, title: String) async throws -> [TimetableMetadata]
    func updateTimetableTheme(timetableID: TimetableID, theme: Theme) async throws -> Timetable
    func setPrimaryTimetable(timetableID: TimetableID) async throws
    func unsetPrimaryTimetable(timetableID: TimetableID) async throws
    func copyTimetable(timetableID: TimetableID) async throws -> [TimetableMetadata]
    func deleteTimetable(timetableID: TimetableID) async throws -> [TimetableMetadata]
    func addLecture(timetableID: TimetableID, lectureID: LectureID, overrideOnConflict: Bool) async throws -> Timetable
    func removeLecture(timetableID: TimetableID, lectureID: TimetableLectureID) async throws -> Timetable
    func createTimetable(title: String, quarter: Quarter) async throws -> [TimetableMetadata]
}

public enum TimetableRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableRepository = {
        let spy = TimetableRepositorySpy()
        spy.fetchTimetableTimetableIDReturnValue = PreviewHelpers.preview(id: "1")
        spy.fetchRecentTimetableReturnValue = PreviewHelpers.preview(id: "1")
        spy.fetchTimetableMetadataListReturnValue = []
        spy.updateTimetableTitleTimetableIDTitleReturnValue = []
        spy.updateTimetableThemeTimetableIDThemeReturnValue = PreviewHelpers.preview(id: "1")
        spy.copyTimetableTimetableIDReturnValue = []
        spy.deleteTimetableTimetableIDReturnValue = []
        spy.addLectureTimetableIDLectureIDOverrideOnConflictReturnValue = PreviewHelpers.preview(id: "1")
        spy.removeLectureTimetableIDLectureIDReturnValue = PreviewHelpers.preview(id: "1")
        spy.createTimetableTitleQuarterReturnValue = []
        return spy
    }()

    public static let previewValue: any TimetableRepository = {
        let spy = TimetableRepositorySpy()
        spy.fetchRecentTimetableReturnValue = PreviewHelpers.preview(id: "1")
        spy.fetchTimetableMetadataListReturnValue = (1...10).map { PreviewHelpers.previewMetadata(with: "\($0)") }
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
