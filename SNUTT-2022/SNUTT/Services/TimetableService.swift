//
//  TimetableService.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation
import SwiftUI

@MainActor
protocol TimetableServiceProtocol: Sendable {
    func fetchRecentTimetable() async throws
    func fetchTimetableList() async throws
    func fetchTimetable(timetableId: String) async throws
    func loadTimetableConfig()
    func copyTimetable(timetableId: String) async throws
    func updateTimetableTitle(timetableId: String, title: String) async throws
    func updateTimetableTheme(timetableId: String) async throws
    func setPrimaryTimetable(timetableId: String) async throws
    func unsetPrimaryTimetable(timetableId: String) async throws
    func deleteTimetable(timetableId: String) async throws
    func selectTimetableTheme(theme: Theme)
    func createTimetable(title: String, quarter: Quarter) async throws
    func setTimetableConfig(config: TimetableConfiguration)
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
        appState.timetable.current = Timetable(from: dto)
    }

    func fetchRecentTimetable() async throws {
        if let localData = userDefaultsRepository.get(TimetableDto.self, key: .currentTimetable) {
            let localTimetable = Timetable(from: localData)
            if appState.user.userId == localTimetable.userId {
                appState.timetable.current = localTimetable // 일단 저장된 시간표로 상태 업데이트
                try await fetchTimetable(timetableId: localTimetable.id) // API 요청을 통해 시간표 최신화
                return
            }
        }
        let dto = try await timetableRepository.fetchRecentTimetable()
        userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: dto)
        appState.timetable.current = Timetable(from: dto)
    }

    func fetchTimetableList() async throws {
        let dtos = try await timetableRepository.fetchTimetableList()
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        appState.timetable.metadataList = timetables
    }

    func createTimetable(title: String, quarter: Quarter) async throws {
        let dtos = try await timetableRepository.createTimetable(title: title, year: quarter.year, semester: quarter.semester.rawValue)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        appState.timetable.metadataList = timetables
    }

    func copyTimetable(timetableId: String) async throws {
        let dtos = try await timetableRepository.copyTimetable(withTimetableId: timetableId)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        appState.timetable.metadataList = timetables
    }

    func updateTimetableTitle(timetableId: String, title: String) async throws {
        let dtos = try await timetableRepository.updateTimetableTitle(withTimetableId: timetableId, withTitle: title)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        appState.timetable.metadataList = timetables
        if appState.timetable.current?.id == timetableId {
            appState.timetable.current?.title = title
        }
    }

    func updateTimetableTheme(timetableId: String) async throws {
        guard let theme = appState.timetable.current?.selectedTheme else { return }
        let dto = try await timetableRepository.updateTimetableTheme(withTimetableId: timetableId, withTheme: theme.rawValue)
        let timetable = Timetable(from: dto)
        if appState.timetable.current?.id == timetableId {
            appState.timetable.current = timetable
        }
    }

    func setPrimaryTimetable(timetableId: String) async throws {
        try await timetableRepository.setPrimaryTimetable(withTimetableId: timetableId)
        try await fetchTimetableList()
    }

    func unsetPrimaryTimetable(timetableId: String) async throws {
        try await timetableRepository.unsetPrimaryTimetable(withTimetableId: timetableId)
        try await fetchTimetableList()
    }

    func deleteTimetable(timetableId: String) async throws {
        guard let currentTimetableId = appState.timetable.current?.id,
              let originalIndex = appState.timetable.metadataList?.firstIndex(where: { $0.id == timetableId })
        else {
            throw STError(.TIMETABLE_NOT_FOUND)
        }

        let dtos = try await timetableRepository.deleteTimetable(withTimetableId: timetableId)
        let timetables = dtos.map { TimetableMetadata(from: $0) }
        appState.timetable.metadataList = timetables

        if timetableId == currentTimetableId {
            let nextIndex = min(originalIndex, timetables.count - 1)
            try await fetchTimetable(timetableId: timetables[nextIndex].id)
        }
    }

    func selectTimetableTheme(theme: Theme) {
        appState.timetable.current?.selectedTheme = theme
    }

    func setTimetableConfig(config: TimetableConfiguration) {
        appState.timetable.configuration = config
        userDefaultsRepository.set(TimetableConfiguration.self, key: .timetableConfig, value: config)
    }

    func loadTimetableConfig() {
        // load asynchronously on startup
        Task { @MainActor in
            var localConfig = userDefaultsRepository.get(TimetableConfiguration.self, key: .timetableConfig, defaultValue: .init())
            if localConfig.maxHour - localConfig.minHour < 6 {
                // fix data integrity
                localConfig.minHour = 9
                localConfig.maxHour = 18
                setTimetableConfig(config: localConfig)
            }
            appState.timetable.configuration = localConfig
        }
    }
}

struct FakeTimetableService: TimetableServiceProtocol {
    func fetchRecentTimetable() async throws {}
    func fetchTimetableList() {}
    func fetchTimetable(timetableId _: String) {}
    func loadTimetableConfig() {}
    func copyTimetable(timetableId _: String) {}
    func updateTimetableTitle(timetableId _: String, title _: String) {}
    func updateTimetableTheme(timetableId _: String) async throws {}
    func setPrimaryTimetable(timetableId _: String) async throws {}
    func unsetPrimaryTimetable(timetableId _: String) async throws {}
    func deleteTimetable(timetableId _: String) async throws {}
    func selectTimetableTheme(theme _: Theme) {}
    func createTimetable(title _: String, quarter _: Quarter) async throws {}
    func setTimetableConfig(config _: TimetableConfiguration) {}
    func setBookmark(lectures _: [Lecture]) {}
}
