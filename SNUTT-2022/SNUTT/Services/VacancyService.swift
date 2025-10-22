//
//  VacancyService.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import Foundation

@MainActor
protocol VacancyServiceProtocol: Sendable {
    func fetchIsFirstVacancy()
    func fetchLectures() async throws
    func fetchSugangSnuUrl() async throws -> URL?
    func addLecture(lecture: Lecture) async throws
    func deleteLectures(lectures: [Lecture]) async throws
    func showVacancyBannerIfNeeded() async throws
    func goToBookmarkPage()
    func goToVacancyPage()
}

struct VacancyService: VacancyServiceProtocol, ConfigsProvidable {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    private var vacancyRepository: any VacancyRepositoryProtocol {
        webRepositories.vacancyRepository
    }

    private var configRepository: any ConfigRepositoryProtocol {
        webRepositories.configRepository
    }

    private var userDefaultsRepository: any UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }
    
    func fetchIsFirstVacancy() {
        appState.vacancy.isFirstVacancy = userDefaultsRepository.get(
            Bool.self,
            key: .isFirstVacancy,
            defaultValue: true
        )
    }

    func fetchLectures() async throws {
        let lectureDtos = try await vacancyRepository.fetchLectures().lectures
        let lectures = lectureDtos
            .map { Lecture(from: $0) }
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
        try await vacancyRepository.addLecture(lectureId: lecture.lectureId ?? lecture.id)
        try await fetchLectures()
    }

    private func deleteLecture(lecture: Lecture) async throws {
        try await vacancyRepository.deleteLecture(lectureId: lecture.lectureId ?? lecture.id)
    }

    func deleteLectures(lectures: [Lecture]) async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for lecture in lectures {
                group.addTask {
                    try await deleteLecture(lecture: lecture)
                }
            }
        })
        try await fetchLectures()
    }

    private func isVacancyNotificationBannerEnabled() async throws -> Bool {
        let configsDto = try await fetchConfigs()
        return configsDto.vacancyNotificationBanner?.visible ?? false
    }

    func fetchSugangSnuUrl() async throws -> URL? {
        let configsDto = try await fetchConfigs()
        return configsDto.vacancySugangSnuUrl?.url
    }

    func showVacancyBannerIfNeeded() async throws {
        guard try await isVacancyNotificationBannerEnabled() else {
            appState.vacancy.isBannerVisible = false
            return
        }

        appState.vacancy.isBannerVisible = true
    }
    
    func goToBookmarkPage() {
        appState.system.selectedTab = .timetable
        appState.routing.timetableScene.pushToBookmark = true
    }

    func goToVacancyPage() {
        appState.system.selectedTab = .timetable
        appState.routing.timetableScene.pushToVacancy = true
    }
}

protocol ConfigsProvidable {
    var appState: AppState { get }
    var webRepositories: AppEnvironment.WebRepositories { get }
    func fetchConfigs() async throws -> ConfigsDto
}

extension ConfigsProvidable {
    @MainActor func fetchConfigs() async throws -> ConfigsDto {
        guard let cachedConfigs = appState.system.configs else {
            let configsDto = try await webRepositories.configRepository.fetchConfigs()
            appState.system.configs = configsDto
            return configsDto
        }
        return cachedConfigs
    }
}

struct FakeVacancyService: VacancyServiceProtocol {
    func fetchSugangSnuUrl() async throws -> URL? {
        return nil
    }

    func showVacancyBannerIfNeeded() async throws {}
    
    func fetchIsFirstVacancy() {}

    func fetchLectures() async throws {}

    func addLecture(lecture _: Lecture) async throws {}

    func deleteLecture(lecture _: Lecture) async throws {}

    func deleteLectures(lectures _: [Lecture]) async throws {}

    func goToBookmarkPage() {}
    func goToVacancyPage() {}
}
