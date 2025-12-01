//
//  LectureDiaryDependencies.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies

struct LectureDiaryRepositoryKey: DependencyKey {
    static let liveValue: any LectureDiaryRepository = LectureDiaryAPIRepository()

    static let previewValue: any LectureDiaryRepository = {
        let spy = LectureDiaryRepositorySpy()
        spy.fetchDiaryListQuarterReturnValue = []
        spy.fetchQuestionnaireReturnValue = []
        return spy
    }()
}

extension DependencyValues {
    var lectureDiaryRepository: any LectureDiaryRepository {
        get { self[LectureDiaryRepositoryKey.self] }
        set { self[LectureDiaryRepositoryKey.self] = newValue }
    }
}
