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
    
    func fetchTimetable(timetableId: String) async throws {
        if appState.setting.timetableSetting.current?.id == timetableId {
            // skip fetching
            return
        }
        let dto = try await timetableRepository.fetchTimetable(timetableId: timetableId)
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.setting.timetableSetting.current = timetable
        }
    }

    func fetchRecentTimetable() async throws {
        if let _ = appState.setting.timetableSetting.current {
            // skip fetching
            return
        }
        let dto = try await timetableRepository.fetchRecentTimetable()
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.setting.timetableSetting.current = timetable
        }
    }
    
    func fetchTimetableList() async throws {
        if let _ = appState.setting.timetableSetting.metadataList {
            // skip fetching
            return
        }
        let dtos = try await timetableRepository.fetchTimetableList()
        let timetables = dtos.map { TimetableMetadata(from: $0)}
        DispatchQueue.main.async {
            appState.setting.timetableSetting.metadataList = timetables
        }
    }
}

struct FakeTimetableService: TimetableServiceProtocol {
    func fetchRecentTimetable() {}
    func fetchTimetableList() {}
    func fetchTimetable(timetableId: String) {}
}
