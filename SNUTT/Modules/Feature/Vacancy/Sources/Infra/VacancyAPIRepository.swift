//
//  VacancyAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import Foundation
import FoundationUtility
import VacancyInterface

public struct VacancyAPIRepository: VacancyRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchVacancyLectures() async throws -> [Components.Schemas.LectureDto] {
        try await apiClient.getVacancyNotificationLectures().ok.body.json.lectures
    }

    public func addVacancyLecture(lectureID: String) async throws {
        _ = try await apiClient.addVacancyNotification(.init(path: .init(lectureId: lectureID))).ok
    }

    public func deleteVacancyLecture(lectureID: String) async throws {
        _ = try await apiClient.deleteVacancyNotification(path: .init(lectureId: lectureID)).ok
    }
    
    public func isVacancyNotificationEnabled(lectureID: String) async throws -> Bool {
        let vacancyLectures = try await fetchVacancyLectures()
        return vacancyLectures.contains { $0._id == lectureID }
    }
}
