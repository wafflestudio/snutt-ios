//
//  VacancyRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import TimetableInterface
import Dependencies
import Spyable

@Spyable
protocol VacancyRepository: Sendable {
    func fetchVacancyLectures() async throws -> [any Lecture]
    func addVacancyLecture(lectureID: String) async throws
    func deleteVacancyLecture(lectureID: String) async throws
}

struct VacancyRepositoryKey: TestDependencyKey {
    static let testValue: any VacancyRepository = VacancyRepositorySpy()
}

extension DependencyValues {
    var vacancyRepository: any VacancyRepository {
        get { self[VacancyRepositoryKey.self] }
        set { self[VacancyRepositoryKey.self] = newValue }
    }
}
