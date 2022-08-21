//
//  TimetableService.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

protocol TimetableServiceProtocol {
    func fetchRecentTimetable() async throws
    func fetchTimetableList() async throws
    func fetchTimetable(timetableId: String) async throws
    func loadTimetableConfig()
}

struct TimetableService: TimetableServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    var timetableRepository: TimetableRepositoryProtocol {
        webRepositories.timetableRepository
    }

    var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    func fetchTimetable(timetableId: String) async throws {
        let dto = try await timetableRepository.fetchTimetable(withTimetableId: timetableId)
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
        await updateState(to: Timetable(from: dto))
    }

    func fetchRecentTimetable() async throws {
        if let cachedData = userDefaultsRepository.get(TimetableDto.self, key: .currentTimetable) {
            await updateState(to: Timetable(from: cachedData))
        }
        let dto = try await timetableRepository.fetchRecentTimetable()
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
        await updateState(to: Timetable(from: dto))
    }

    func fetchTimetableList() async throws {
        let dtos = try await timetableRepository.fetchTimetableList()
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        DispatchQueue.main.async {
            appState.timetable.metadataList = timetables
        }
    }

    func loadTimetableConfig() {
        DispatchQueue.main.async {
            appState.timetable.configuration = userDefaultsRepository.get(TimetableConfiguration.self, key: .timetableConfig, defaultValue: .init())
        }
    }

    // TODO: to be refactored
    @MainActor
    private func updateState(to currentTimetable: Timetable) {
        appState.timetable.current = currentTimetable
    }
}

struct FakeTimetableService: TimetableServiceProtocol {
    func fetchRecentTimetable() {}
    func fetchTimetableList() {}
    func fetchTimetable(timetableId _: String) {}
    func loadTimetableConfig() {}
}
