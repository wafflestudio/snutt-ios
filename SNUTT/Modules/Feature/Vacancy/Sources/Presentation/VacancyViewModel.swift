//
//  VacancyViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Observation
import TimetableInterface

@MainActor
@Observable
final class VacancyViewModel {
    @ObservationIgnored
    @Dependency(\.vacancyRepository) private var vacancyRepository

    private(set) var vacancyLectures: [Lecture] = []

    func fetchVacancyLectures() async throws {
        let lectureDtos = try await vacancyRepository.fetchVacancyLectures()
        vacancyLectures = try lectureDtos.map { try $0.toLecture() }
    }

    func deleteVacancyLectures(lectureIDs: Set<String>) async throws {
        vacancyLectures.removeAll(where: { lectureIDs.contains($0.id) })
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for lectureID in lectureIDs {
                    group.addTask {
                        try await self.vacancyRepository.deleteVacancyLecture(lectureID: lectureID)
                    }
                }
                try await group.waitForAll()
            }
        } catch {
            try? await fetchVacancyLectures()
            throw error
        }
    }
}
