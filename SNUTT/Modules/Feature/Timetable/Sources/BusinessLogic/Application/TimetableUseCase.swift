//
//  TimetableUseCase.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import AuthInterface
import Dependencies
import DependenciesAdditions
import DependenciesUtility
import Foundation
import Spyable
import TimetableInterface

struct TimetableUseCase {
    @Dependency(\.timetableRepository) private var timetableRepository
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository
    @Dependency(\.userDefaults) private var userDefaults
    @Dependency(\.authState) private var authState

    func loadRecentTimetable() async throws -> any Timetable {
        if let localTimetable = try? timetableLocalRepository.loadSelectedTimetable(),
           authState.get(.userID) == localTimetable.userID
        {
            return localTimetable
        }
        let timetable = try await timetableRepository.fetchRecentTimetable()
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }

    func selectTimetable(timetableID: String) async throws -> any Timetable {
        let timetable = try await timetableRepository.fetchTimetable(timetableID: timetableID)
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }
}

private struct TimetableUseCaseKey: DependencyKey {
    static let liveValue: TimetableUseCase = withDependencies {
        $0.userDefaults = .init(suitename: "group.\($0.bundleInfo.bundleIdentifier)") ?? .standard
    } operation: {
        TimetableUseCase()
    }
}

extension DependencyValues {
    var timetableUseCase: TimetableUseCase {
        get { self[TimetableUseCaseKey.self] }
        set { self[TimetableUseCaseKey.self] = newValue }
    }
}
