//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import TimetableInterface

extension TimetableLocalRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableLocalRepository =
        TimetableUserDefaultsRepository()

    public static let previewValue: any TimetableLocalRepository = {
        let spy = TimetableLocalRepositorySpy()
        spy.loadSelectedTimetableReturnValue = PreviewHelpers.preview(id: "1")
        return spy
    }()
}

struct LectureRepositoryKey: DependencyKey {
    static let liveValue: any LectureRepository = LectureAPIRepository()

    static let previewValue: any LectureRepository = {
        let spy = LectureRepositorySpy()
        spy.fetchBuildingListPlacesReturnValue = []
        spy.isBookmarkedLectureIDReturnValue = false
        return spy
    }()
}

struct LectureSearchRepositoryKey: DependencyKey {
    static let liveValue: any LectureSearchRepository = LectureSearchAPIRepository()
    static let previewValue: any LectureSearchRepository = {
        let spy = LectureSearchRepositorySpy()
        spy.fetchSearchResultQueryQuarterPredicatesOffsetLimitReturnValue = PreviewHelpers.preview(id: "1").lectures
        spy.fetchSearchPredicatesQuarterReturnValue = [
            .classification("교양"),
            .classification("일반"),
            .department("경영학과"),
            .department("컴퓨터공학부"),
            .credit(1),
            .credit(2),
            .category("과학적 사고와 실험"),
            .category("인간과 세계"),
            .academicYear("1학년"),
            .academicYear("2학년"),
            .sortCriteria("평점 높은 순"),
            .sortCriteria("강의평 많은 순"),
        ]
        return spy
    }()
}

struct CourseBookRepositoryKey: DependencyKey {
    static let liveValue: any CourseBookRepository = CourseBookAPIRepository()

    static let previewValue: any CourseBookRepository = {
        let spy = CourseBookRepositorySpy()
        spy.fetchCourseBookListReturnValue = []
        return spy
    }()
}

extension DependencyValues {
    var lectureRepository: any LectureRepository {
        get { self[LectureRepositoryKey.self] }
        set { self[LectureRepositoryKey.self] = newValue }
    }

    var lectureSearchRepository: any LectureSearchRepository {
        get { self[LectureSearchRepositoryKey.self] }
        set { self[LectureSearchRepositoryKey.self] = newValue }
    }

    var courseBookRepository: any CourseBookRepository {
        get { self[CourseBookRepositoryKey.self] }
        set { self[CourseBookRepositoryKey.self] = newValue }
    }
}
