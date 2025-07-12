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
import ThemesInterface
import TimetableInterface

public struct TimetableUseCase: Sendable {
    @Dependency(\.timetableRepository) private var timetableRepository
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository
    @Dependency(\.authState) private var authState

    func loadLocalRecentTimetable() -> Timetable? {
        guard let timetable = try? timetableLocalRepository.loadSelectedTimetable(),
            authState.get(.userID) == timetable.userID
        else { return nil }
        return timetable
    }

    func fetchRecentTimetable() async throws -> Timetable {
        let timetable = try await timetableRepository.fetchRecentTimetable()
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }

    func selectTimetable(timetableID: String) async throws -> Timetable {
        let timetable = try await timetableRepository.fetchTimetable(timetableID: timetableID)
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }

    func addLecture(
        timetableID: String,
        lectureID: String,
        overrideOnConflict: Bool = false
    ) async throws -> Timetable {
        let timetable = try await timetableRepository.addLecture(
            timetableID: timetableID,
            lectureID: lectureID,
            overrideOnConflict: overrideOnConflict
        )
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }

    func removeLecture(timetableID: String, lectureID: String) async throws -> Timetable {
        let timetable = try await timetableRepository.removeLecture(timetableID: timetableID, lectureID: lectureID)
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }

    public func updateTheme(timetableID: String, theme: Theme) async throws -> Timetable {
        let timetable = try await timetableRepository.updateTimetableTheme(timetableID: timetableID, theme: theme)
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
    public var timetableUseCase: TimetableUseCase {
        get { self[TimetableUseCaseKey.self] }
        set { self[TimetableUseCaseKey.self] = newValue }
    }
}
