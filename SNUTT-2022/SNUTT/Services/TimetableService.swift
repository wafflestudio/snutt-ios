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
    func loadTimetable() -> TimetableDto?
    func loadConfiguration() -> TimetableConfiguration
    func cache(timetable: TimetableDto)
    func cache(configuration: TimetableConfiguration)
}

struct TimetableService: TimetableServiceProtocol {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories

    var timetableRepository: TimetableRepositoryProtocol {
        webRepositories.timetableRepository
    }

    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }

    func loadTimetable() -> TimetableDto? {
        return timetableRepository.loadTimetable()
    }

    func loadConfiguration() -> TimetableConfiguration {
        return timetableRepository.loadConfiguration()
    }

    func cache(timetable: TimetableDto) {
        timetableRepository.cache(timetable: timetable)
    }

    func cache(configuration: TimetableConfiguration) {
        timetableRepository.cache(configuration: configuration)
    }

    func fetchTimetable(timetableId: String) async throws {
        let dto = try await timetableRepository.fetchTimetable(withTimetableId: timetableId)
        cache(timetable: dto)
        updateState(to: Timetable(from: dto))
    }

    func fetchRecentTimetable() async throws {
        if let cachedData = loadTimetable() {
            updateState(to: Timetable(from: cachedData))
        }
        let dto = try await timetableRepository.fetchRecentTimetable()
        cache(timetable: dto)
        updateState(to: Timetable(from: dto))
    }

    func fetchTimetableList() async throws {
        let dtos = try await timetableRepository.fetchTimetableList()
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        DispatchQueue.main.async {
            appState.timetable.metadataList = timetables
        }
    }

    private func updateState(to currentTimetable: Timetable) {
        DispatchQueue.main.async {
            appState.timetable.current = currentTimetable
        }
    }
}

struct FakeTimetableService: TimetableServiceProtocol {
    func loadTimetable() -> TimetableDto? { return nil }
    func loadConfiguration() -> TimetableConfiguration { return .init() }
    func cache(timetable _: TimetableDto) {}
    func cache(configuration _: TimetableConfiguration) {}
    func fetchRecentTimetable() {}
    func fetchTimetableList() {}
    func fetchTimetable(timetableId _: String) {}
}
