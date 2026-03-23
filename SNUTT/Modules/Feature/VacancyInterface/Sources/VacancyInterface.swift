//
//  VacancyInterface.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Spyable
import SwiftUI
import TimetableInterface

@MainActor
public protocol VacancyUIProvidable {
    associatedtype Content: View
    func makeVacancyScene() -> Content
}

// MARK: - VacancyRepository

@Spyable
public protocol VacancyRepository: Sendable {
    func fetchVacancyLectures() async throws -> [Components.Schemas.LectureDto]
    func addVacancyLecture(lectureID: LectureID) async throws
    func deleteVacancyLecture(lectureID: LectureID) async throws
    func isVacancyNotificationEnabled(lectureID: LectureID) async throws -> Bool
}

public enum VacancyRepositoryKey: TestDependencyKey {
    public static let testValue: any VacancyRepository = {
        let spy = VacancyRepositorySpy()
        spy.fetchVacancyLecturesReturnValue = []
        spy.isVacancyNotificationEnabledLectureIDReturnValue = true
        return spy
    }()
}

extension DependencyValues {
    public var vacancyRepository: any VacancyRepository {
        get { self[VacancyRepositoryKey.self] }
        set { self[VacancyRepositoryKey.self] = newValue }
    }
}

private struct EmptyVacancyUIProvider: VacancyUIProvidable {
    func makeVacancyScene() -> Text {
        Text("VacancyUIProvider not found.")
    }
}

extension EnvironmentValues {
    @Entry public var vacancyUIProvider: any VacancyUIProvidable = EmptyVacancyUIProvider()
}
