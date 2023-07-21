//
//  VacancyService.swift
//  SNUTT
//
//  Created by user on 2023/07/22.
//

import Foundation

@MainActor
protocol VacancyServiceProtocol: Sendable {
    func fetchLectures() async throws
    func addLecture(lecture: Lecture) async throws
    func deleteLecture(lecture: Lecture) async throws
    func deleteLectures(lectures: [Lecture]) async throws
}

struct VacancyService: VacancyServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    private var vacancyRepository: any VacancyRepositoryProtocol {
        webRepositories.vacancyRepository
    }

    func fetchLectures() async throws {
        let lectureDtos = try await vacancyRepository.fetchLectures()
        let lectures = lectureDtos
            .map({ Lecture(from: $0) })
            .sorted {
                if $0.hasVacancy != $1.hasVacancy {
                    return $0.hasVacancy
                } else {
                    return $0.title < $1.title
                }
            }
        appState.vacancy.lectures = lectures
    }

    func addLecture(lecture: Lecture) async throws {
        try await vacancyRepository.addLecture(lectureId: lecture.id)
        try await fetchLectures()
    }

    func deleteLecture(lecture: Lecture) async throws {
        try await vacancyRepository.deleteLecture(lectureId: lecture.id)
        try await fetchLectures()
    }

    func deleteLectures(lectures: [Lecture]) async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for lecture in lectures {
                group.addTask {
                    try await deleteLecture(lecture: lecture)
                }
            }
        })
    }

}

struct FakeVacancyService: VacancyServiceProtocol {
    func fetchLectures() async throws {
    }
    
    func addLecture(lecture: Lecture) async throws {
    }
    
    func deleteLecture(lecture: Lecture) async throws {
    }

    func deleteLectures(lectures: [Lecture]) async throws {}
}
