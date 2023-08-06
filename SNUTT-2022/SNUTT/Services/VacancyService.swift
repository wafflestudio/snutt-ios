//
//  VacancyService.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import Foundation

@MainActor
protocol VacancyServiceProtocol: Sendable {
    func fetchLectures() async throws
    func addLecture(lecture: Lecture) async throws
    func deleteLectures(lectures: [Lecture]) async throws
    func showVacancyBannerIfNeeded() async throws
    func dismissVacancyNotificationBanner()
    func goToVacancyPage()
}

struct VacancyService: VacancyServiceProtocol {
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

    func fetchLectures() async throws {
        let lectureDtos = try await vacancyRepository.fetchLectures()
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
        try await vacancyRepository.addLecture(lectureId: lecture.id)
        try await fetchLectures()
    }

    private func deleteLecture(lecture: Lecture) async throws {
        try await vacancyRepository.deleteLecture(lectureId: lecture.id)
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
        if let cachedConfigs = appState.system.configs {
            return cachedConfigs.vacancyNotificationBanner.visible
        }
        let configsDto = try await configRepository.fetchConfigs()
        appState.system.configs = configsDto
        return configsDto.vacancyNotificationBanner.visible
    }

    func showVacancyBannerIfNeeded() async throws {
        guard try await isVacancyNotificationBannerEnabled() else {
            appState.vacancy.isBannerVisible = false
            return
        }

        if let lastDismissedAt = userDefaultsRepository.get(Date.self, key: .vacancyBannerDismissedAt),
           Date().daysFrom(lastDismissedAt) < 1
        {
            appState.vacancy.isBannerVisible = false
            return
        }

        appState.vacancy.isBannerVisible = true
    }

    func dismissVacancyNotificationBanner() {
        userDefaultsRepository.set(Date.self, key: .vacancyBannerDismissedAt, value: Date())
        appState.vacancy.isBannerVisible = false
    }

    func goToVacancyPage() {
        appState.system.selectedTab = .settings
        appState.routing.settingScene.pushToVacancy = true
    }
}

struct FakeVacancyService: VacancyServiceProtocol {
    func dismissVacancyNotificationBanner() {}

    func showVacancyBannerIfNeeded() async throws {}

    func fetchLectures() async throws {}

    func addLecture(lecture _: Lecture) async throws {}

    func deleteLecture(lecture _: Lecture) async throws {}

    func deleteLectures(lectures _: [Lecture]) async throws {}

    func goToVacancyPage() {}
}
