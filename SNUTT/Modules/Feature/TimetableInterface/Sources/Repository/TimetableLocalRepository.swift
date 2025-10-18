//
//  TimetableLocalRepository.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol TimetableLocalRepository: Sendable {
    func loadSelectedTimetable() throws -> Timetable
    func storeSelectedTimetable(_ timetable: Timetable) throws
    func loadTimetableConfiguration() -> TimetableConfiguration
    func storeTimetableConfiguration(_ configuration: TimetableConfiguration)
    func configurationValues() -> AsyncStream<TimetableConfiguration>
}

public enum TimetableLocalRepositoryKey: TestDependencyKey {
    public static let testValue: any TimetableLocalRepository = {
        let spy = TimetableLocalRepositorySpy()
        spy.loadSelectedTimetableReturnValue = PreviewHelpers.preview(id: "1")
        spy.loadTimetableConfigurationReturnValue = .init()
        spy.configurationValuesReturnValue = .finished
        return spy
    }()
}

extension DependencyValues {
    public var timetableLocalRepository: any TimetableLocalRepository {
        get { self[TimetableLocalRepositoryKey.self] }
        set { self[TimetableLocalRepositoryKey.self] = newValue }
    }
}
