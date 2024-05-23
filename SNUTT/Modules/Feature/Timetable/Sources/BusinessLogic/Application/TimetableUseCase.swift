//
//  TimetableUseCase.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesAdditions
import Foundation
import DependenciesUtility
import TimetableInterface
import APIClientInterface
import AuthInterface
import Spyable

@Spyable
protocol TimetableUseCaseProtocol: Sendable {
    func loadRecentTimetable() async throws -> any Timetable
}

extension TimetableUseCaseProtocolSpy: @unchecked Sendable {}

struct TimetableUseCase: TimetableUseCaseProtocol {
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
}

private struct TimetableUseCaseKey: DependencyKey {
    static let liveValue: any TimetableUseCaseProtocol = {
        withDependencies {
            $0.userDefaults = .init(suitename: "group.\($0.bundleInfo.bundleIdentifier)") ?? .standard
        } operation: {
            TimetableUseCase()
        }
    }()
    static let previewValue: any TimetableUseCaseProtocol = {
        let spy = TimetableUseCaseProtocolSpy()
        spy.loadRecentTimetableReturnValue = PreviewTimetable.preview
        return spy
    }()
}

extension DependencyValues {
    var timetableUseCase: any TimetableUseCaseProtocol {
        get { self[TimetableUseCaseKey.self] }
        set { self[TimetableUseCaseKey.self] = newValue }
    }
}
