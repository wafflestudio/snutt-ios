//
//  VacancyRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import TimetableInterface

@Spyable
public protocol VacancyRepository: Sendable {
    func fetchVacancyLectures() async throws -> [any Lecture]
    func addVacancyLecture(lectureID: String) async throws
    func deleteVacancyLecture(lectureID: String) async throws
}

public struct VacancyRepositoryKey: TestDependencyKey {
    public static let testValue: any VacancyRepository = {
        let spy = VacancyRepositorySpy()
        spy.fetchVacancyLecturesReturnValue = PreviewHelpers.preview.lectures
        return spy
    }()
}

extension DependencyValues {
    var vacancyRepository: any VacancyRepository {
        get { self[VacancyRepositoryKey.self] }
        set { self[VacancyRepositoryKey.self] = newValue }
    }
}
