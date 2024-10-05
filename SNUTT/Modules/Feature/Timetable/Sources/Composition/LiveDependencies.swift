//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import TimetableInterface

struct TimetableLocalRepositoryKey: DependencyKey {
    static let liveValue: any TimetableLocalRepository = TimetableUserDefaultsRepository<Components.Schemas.TimetableLegacyDto>()
}

struct LectureSearchRepositoryKey: DependencyKey {
    static let liveValue: any LectureSearchRepository = LectureSearchAPIRepository()
    static let previewValue: any LectureSearchRepository = {
        let spy = LectureSearchRepositorySpy()
        spy.fetchSearchResultQueryQuarterFiltersOffsetLimitReturnValue = PreviewTimetable.preview.lectures
        return spy
    }()
}

extension DependencyValues {
    var timetableLocalRepository: any TimetableLocalRepository {
        get { self[TimetableLocalRepositoryKey.self] }
        set { self[TimetableLocalRepositoryKey.self] = newValue }
    }

    var lectureSearchRepository: any LectureSearchRepository {
        get { self[LectureSearchRepositoryKey.self] }
        set { self[LectureSearchRepositoryKey.self] = newValue }
    }
}
