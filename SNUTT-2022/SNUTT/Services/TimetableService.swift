//
//  TimetableService.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import Foundation

protocol TimetableServiceProtocol {}

struct TimetableService: TimetableServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories

    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }
}

struct FakeTimetableService: TimetableServiceProtocol {}
