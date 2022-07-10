//
//  TimetableService.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

protocol TimetableServiceProtocol {
    func fetchRecentTimetable() async throws
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
    
    func fetchRecentTimetable() async throws {
        let dto = try await timetableRepository.fetchRecentTimetable()
        let timetable = Timetable(from: dto)
        DispatchQueue.main.async {
            appState.setting.timetableSetting.current = timetable
        }
    }
}

struct FakeTimetableService: TimetableServiceProtocol {
    func fetchRecentTimetable() {
    }
}
