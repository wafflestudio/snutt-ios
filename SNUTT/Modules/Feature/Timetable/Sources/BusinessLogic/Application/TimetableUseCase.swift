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

public struct TimetableUseCase: Sendable {
    @Dependency(\.timetableRepository) private var timetableRepository
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository
    @Dependency(\.userDefaults) private var userDefaults
    @Dependency(\.authState) private var authState

    public func loadRecentTimetable() async throws -> any Timetable {
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

    func addLecture(timetableID: String, lectureID: String) async throws -> any Timetable {
        let timetable = try await timetableRepository.addLecture(timetableID: timetableID, lectureID: lectureID)
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }

    func removeLecture(timetableID: String, lectureID: String) async throws -> any Timetable {
        let timetable = try await timetableRepository.removeLecture(timetableID: timetableID, lectureID: lectureID)
        try timetableLocalRepository.storeSelectedTimetable(timetable)
        return timetable
    }
}

extension TimetableUseCase: DependencyKey {
    public static let liveValue: TimetableUseCase = withDependencies {
        $0.userDefaults = .init(suitename: "group.\($0.bundleInfo.bundleIdentifier)") ?? .standard
    } operation: {
        TimetableUseCase()
    }
}

extension DependencyValues {
    public var timetableUseCase: TimetableUseCase {
        get { self[TimetableUseCase.self] }
        set { self[TimetableUseCase.self] = newValue }
    }
}
